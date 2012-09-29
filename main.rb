#!/Users/alex/.rvm/rubies/ruby-1.9.2-p290/bin/ruby -w
# -*- coding: utf-8 -*-
require 'sqlite3'

class TTDataStore

  def initialize dbname=".timetrackerdb", timezone="+02:00", version='v0.1', verbosity=0
    @dbname = dbname
    @timezone = timezone
    @version = version
    @verbosity = verbosity

    if FileTest.zero?(dbname) or not FileTest.file?(dbname)
      @db = SQLite3::Database.new( dbname )
      createschema
      init(timezone, version, verbosity)
    else
      @db = SQLite3::Database.open( dbname )
    end
  end

  private
  def createschema
    @db.execute <<-SQL
    CREATE TABLE system (
      current,
      latest,
      timezone NOT NULL,
      version INTEGER NOT NULL,
      verbosity NOT NULL,
      redmine
    )
    SQL

    @db.execute <<-SQL
    CREATE TABLE timesheet (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name,
      tstart DEFAULT CURRENT_TIMESTAMP,
      tstop,
      synced DEFAULT 'false',
      notes
    )
    SQL
  end

  def init timezone, version, verbosity
    @db.execute 'INSERT INTO system ( timezone, version, verbosity ) VALUES ( "%s", "%s", "%s" )' %
      [timezone, version, verbosity]
  end

  def droptables
    for table in ['system', 'timesheet']
      @db.execute 'DROP TABLE IF EXISTS %s' % table
    end
  end

  def setcurrent issueid
    oldcurrent = @db.execute 'SELECT current, latest FROM system'
    @db.execute "UPDATE system SET current = '%d', latest = '%s'" %
      [issueid, oldcurrent[0][0] != '' ? oldcurrent[0][0] : oldcurrent[0][1]]
  end

  public
  def getcurrent
    current = @db.execute "SELECT current FROM system"
    current[0][0] == "" ? nil : current[0][0]
  end

  def getstatus
    current = getcurrent
    if current
      status = @db.execute "SELECT id,name FROM timesheet WHERE id=%d" % current
      status[0]
    else
      nil
    end
  end

  def startnew issuename, notes=''
    @db.execute "INSERT INTO timesheet ( name, notes ) VALUES ( '%s', '%s' )" %
      [issuename, notes]
    latest = @db.execute "SELECT id FROM timesheet ORDER BY id DESC LIMIT 1"
    setcurrent latest[0][0]
  end

  def stoprunning
    current = getcurrent
    if current
      @db.execute "UPDATE timesheet set tstop = datetime('now') WHERE id = %d" % current
      @db.execute "UPDATE system SET current = '', latest = '%d'" % current
    else
      p "Not tracking"
    end
  end

  def gettime issueid=false
    issueid = issueid ? issueid : getcurrent
    if issueid
      time = @db.execute "SELECT tstart,tstop FROM timesheet WHERE id=%d" % issueid
      time[0]
    else
      false
    end
  end

  def gettimesbyissuename issuename
    @db.execute "SELECT tstart,tstop FROM timesheet WHERE name='%s'" % issuename
  end

  def getissuesandtimesbyname issuename
    @db.execute "SELECT tstart,tstop FROM timesheet WHERE name='%s'" % issuename
  end

  def getissuesidsbyname issuename
    @db.execute "SELECT id,tstart,tstop,notes FROM timesheet WHERE name='%s'" % issuename
  end

  def settstart id, tstart
    @db.execute "UPDATE timesheet SET tstart=datetime('%s') WHERE id=%d" % [tstart, id]
  end

  def settstop id, tstop
    @db.execute "UPDATE timesheet SET tstop=datetime('%s') WHERE id=%d" % [tstop, id]
  end

  def cleanup
    droptables
    createschema
    init(@timezone, @version, @verbosity)
  end

end  # End DataStore class


class TimeTracker

  def initialize
    @db = TTDataStore.new
  end

  def start issuename, notes
    unless issuename == nil
      if @db.getcurrent
        @db.stoprunning
      end
      @db.startnew issuename, notes
    else
      usage
    end
  end

  def stop
    @db.stoprunning
  end

  def status issuename
    unless issuename
      status = @db.getstatus
      if status
        delta = Time.now - gettstart(@db.getcurrent)
        p "Task '%s' run time: %d seconds (%.2f hours)" % [status[1], delta, delta / 3600]
      else
        p "Not tracking"
      end
    else
      total = gettotalissueduration(issuename)
      unless total == 0
        p "Total seconds for task %s: %d (%.2f hours)" % 
          [
            issuename,
            total,
            total / 3600
          ]
      else
        p "No entry for issue '%s'" % issuename
      end
    end
  end

  def report issuename
    r = @db.getissuesidsbyname issuename
    unless r == []
      p "id | tstart | tstop | notes"
      r.each do |x|
        p "%s | %s | %s | %s" % x
      end
    else
      usage
    end
  end

  def setstart issueid, timestamp
    t = validatetimestamp timestamp
    @db.settstart issueid, t
  end

  def setstop issueid, timestamp
    t = validatetimestamp timestamp
    @db.settstop issueid, t
  end

  def init
    @db.cleanup
  end

  def usage
    p "Usage: %s [start|stop|status|init|report|begin|end] issue_name" % $0
  end

  private
  def gettimeobject timestamp
    if timestamp
      Time.utc(
        timestamp[0,4],
        timestamp[5,7],
        timestamp[8,10],
        timestamp[11,13],
        timestamp[14,16],
        timestamp[17,19]
      )
    else
      Time.now
    end
  end

  def validatetimestamp timestamp
    t = Time.utc(
        timestamp[0,4],
        timestamp[5,7],
        timestamp[8,10],
        timestamp[11,13],
        timestamp[14,16],
        timestamp[17,19]
      )
    "%.4d-%.2d-%.2d %.2d:%.2d:%.2d" % [
      t.year,
      t.month,
      t.day,
      t.hour,
      t.min,
      t.sec
    ]
  end

  def gettotalissueduration issuename
    r = @db.getissuesandtimesbyname(issuename)
    total = 0
    r.each do |timestamps|
      if timestamps[0]
        t0, t1 = gettimeobject(timestamps[0]), gettimeobject(timestamps[1])
        total = total + (t1 - t0)
      end
    end
    total
  end

  def getissueduration issueid
    timestamps = @db.gettime issueid
    if timestamps and timestamps[1]
      t0, t1 = gettimeobject(timestamps[0]), gettimeobject(timestamps[1])
      t1 - t0
    else
      false
    end
  end

  def gettstart issueid
    timestamps = @db.gettime issueid
    unless timestamps[0] == nil
      gettimeobject timestamps[0]
    end
  end

  def gettstop issueid
    timestamps = @db.gettime issueid
    unless timestamps[1] == nil
      gettimeobject timestamps[1]
    end
  end

end  # End TimeTracker class


tt = TimeTracker.new
case ARGV[0]
  when 'start' then
    tt.start ARGV[1], ARGV[2]
  when 'stop' then
    tt.stop
  when 'status' then
    tt.status ARGV[1]
  when 'init' then
    tt.init
  when 'report' then
    tt.report ARGV[1]
  when 'beguin' then
    timestamp = ARGV[3] ? "%s %s" % ARGV[2,3] : ARGV[2]
    tt.setstart ARGV[1], timestamp
  when 'end' then
    timestamp = ARGV[3] ? "%s %s" % ARGV[2,3] : ARGV[2]
    tt.setstop ARGV[1], timestamp
  else tt.usage
end


# TODO: add support for timezone
