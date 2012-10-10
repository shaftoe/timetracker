# -*- coding: utf-8 -*-
#
# = TTrack class
#
# Class that handles communication between CLI and data storage
#
class TTrack

  # At each call we need to declare the datastore
  def initialize datastore
    @db = DataStore.new datastore
  end

  # Start tracking an issue, stop the current one if running
  # Return boolean to indicate if the action was succesfull or not
  def start issuename, notes=''
    unless issuename.nil? or issuename.empty?
      @db.stoprunning if @db.getcurrent
      @db.startnew issuename, notes
      true
    else
      false
    end
  end

  # Stop the current running task
  # Return false if no current running task, true otherwise
  def stop
    @db.stoprunning ? true : false
  end

  def status issuename=nil
    if issuename.nil?
      status = @db.getstatus
      if status
        delta = Time.now - gettstart(@db.getcurrent)
        {:task => status[1], :elapsed => delta, :elapsed_hours => (delta / 3600)}
      end
    else
      total = gettotalissueduration(issuename)
      unless total == 0
        {:task => issuename, :elapsed => total, :elapsed_hours => (total / 3600)}
      end
    end
  end

  def report issuename
    if issuename.nil?
      r = @db.gettimesheet
      pstring = "%s | %s | %s | %s | %s | %d"
      puts "id | name | tstart | tstop | notes | duration"
    else
      r = @db.getissuesidsbyname issuename
      pstring = "%s | %s | %s | %s | %d"
      puts "id | tstart | tstop | notes | duration"
    end
    unless r[0].nil?
        r.each do |x|
        x << getissueduration(x[0])
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
    t0, t1 = gettimeobject(timestamps[0]), gettimeobject(timestamps[1])
    t1 - t0
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
