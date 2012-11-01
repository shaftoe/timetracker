# -*- coding: utf-8 -*-
require 'sqlite3'

class TTrack::DataStore

  def initialize dbname, timezone="+02:00", version='v0.3.2', verbosity=0
    @dbname = dbname
    @timezone = timezone
    @version = version
    @verbosity = verbosity

    if FileTest.zero?(@dbname) or not FileTest.file?(@dbname)
      @db = SQLite3::Database.new( @dbname )
      createschema
      init(timezone, version, verbosity)
    else
      @db = SQLite3::Database.open( @dbname )
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
    current[0][0] == "" ? false : current[0][0]
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

  def startnew issuename, notes
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
      current.to_i
    else
      false
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

  def gettimesheet
    @db.execute "SELECT id,name,tstart,tstop,synced,notes FROM timesheet"
  end

  def gettimesbyissuename issuename
    @db.execute "SELECT tstart,tstop FROM timesheet WHERE name='%s'" % issuename
  end

  def getissuesandtimesbyname issuename
    @db.execute "SELECT tstart,tstop FROM timesheet WHERE name='%s'" % issuename
  end

  def getissuesbyname issuename
    @db.execute "SELECT id,tstart,tstop,synced, notes FROM timesheet WHERE name='%s'" % issuename
  end

  def getnamebyissueid issueid
    result = @db.execute "SELECT name FROM timesheet WHERE id=%d" % issueid
  end

  def settstart id, tstart
    @db.execute "UPDATE timesheet SET tstart=datetime('%s') WHERE id=%d" % [tstart, id]
  end

  def settstop id, tstop
    @db.execute "UPDATE timesheet SET tstop=datetime('%s') WHERE id=%d" % [tstop, id]
  end

  def isissue? id
    r = @db.execute "SELECT id from timesheet WHERE id=%d" % id
    r[0].nil? ? false : true
  end

  def cleanup
    droptables
    createschema
    init(@timezone, @version, @verbosity)
  end

end  # End DataStore class