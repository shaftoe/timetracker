# -*- coding: utf-8 -*-
class TTrack

  def initialize
    @db = DataStore.new
  end

  def start issuename, notes
    unless issuename.nil?
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
        puts "Task '%s' run time: %d seconds (%.2f hours)" % [status[1], delta, delta / 3600]
      else
        puts "Not tracking"
      end
    else
      total = gettotalissueduration(issuename)
      unless total == 0
        puts "Total seconds for task %s: %d (%.2f hours)" % 
          [
            issuename,
            total,
            total / 3600
          ]
      else
        puts "No entry for issue '%s'" % issuename
      end
    end
  end

  def report issuename
    if issuename.nil?
      r = @db.gettimesheet
      pstring = "%s | %s | %s | %s | %s"
      puts "id | name | tstart | tstop | notes"
    else
      r = @db.getissuesidsbyname issuename
      pstring = "%s | %s | %s | %s"
      puts "id | tstart | tstop | notes"
    end
    unless r[0].nil?
        r.each do |x|
        puts pstring % x
      end
    else
      usage
    end
  end

  def setstart issueid, timestamp
    if validateissueid issueid
      t = validatetimestamp timestamp
      @db.settstart issueid, t
    end
  end

  def setstop issueid, timestamp
    if validateissueid issueid
      t = validatetimestamp timestamp
      @db.settstop issueid, t
    end
  end

  def init
    @db.cleanup
  end

  def usage
    puts "Usage: ttrack [start|stop|status|init|report|begin|end] issue_name"
  end

  private
  def gettimeobject timestamp
    if timestamp
      Time.utc(
        timestamp[0..3],
        timestamp[5..6],
        timestamp[8..9],
        timestamp[11..12],
        timestamp[14..15],
        timestamp[17..18]
      )
    else
      Time.now
    end
  end

  def validatetimestamp timestamp
    t = Time.utc(
        timestamp[0..3],
        timestamp[5..6],
        timestamp[8..9],
        timestamp[11..12],
        timestamp[14..15],
        timestamp[17..18]
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

  def validateissueid issueid
    unless @db.isissue? issueid
      puts "Issueid invalid"
      false
    else
      true
    end
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
    unless timestamps[0].nil?
      gettimeobject timestamps[0]
    end
  end

  def gettstop issueid
    timestamps = @db.gettime issueid
    unless timestamps[1].nil?
      gettimeobject timestamps[1]
    end
  end

end  # End TTrack class

require 'ttrack/datastore'
# TODO: add support for timezone
# TODO: fix default db location, should be in $HOME/
