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
  # Return info about the stopped running task, false if it was not tracking
  def stop
    result = @db.stoprunning
    if result and result != []
      { :name => @db.getnamebyissueid(result)[0][0], :id => result, :elapsed => getissueduration(result) }
    else
      false
    end
  end

  # Get current running task status if no issuename given
  # Otherwise get total duration for named task (i.e. for any matching time entry)
  def status issuename=nil
    if issuename.nil?
      status = @db.getstatus
      if status
        delta = Time.now - gettstart(@db.getcurrent)
        {:task => status[1], :elapsed => delta}
      end
    else
      total = gettotalissueduration(issuename)
      unless total.nil?
        {:task => issuename, :elapsed => total}
      end
    end
  end

  # Get a report for the given issue name
  # If no issue is give, get a report for everything
  def report issuename=nil
    result = Array.new

    if issuename.nil? or issuename.empty?
      r = @db.gettimesheet
      r.each do |line|
          result << {
          :task => line[0],
          :name => line[1],
          :tstart => line[2],
          :tstop => line[3],
          :synced => line[4],
          :notes => line[5],
          :elapsed => getissueduration(line[0])
        }
      end
    else
      r = @db.getissuesbyname issuename
      r.each do |line|
          result << {
          :task => line[0],
          :tstart => line[1],
          :tstop => line[2],
          :synced => line[3],
          :notes => line[4],
          :elapsed => getissueduration(line[0])
        }
      end
    end
    result.empty? ? nil : result
  end

  # Overwrite tstart for given issue with given timestamp
  def set_tstart! issueid, timestamp
    if validateissueid(issueid)
      t = validatetimestamp(timestamp)
      @db.settstart(issueid, t)
      true
    else
      false
    end
  end

  # Override tstop for given issue
  def set_tstop! issueid, timestamp
    if validateissueid issueid
      t = validatetimestamp timestamp
      @db.settstop issueid, t
    end
  end

  # Cleanup the database
  def init
    @db.cleanup
  end

  # List of available public methods
  def commands
    [:start, :stop, :status, :init, :report, :begin, :end]
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
    r[0].nil? ? nil : total
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
# TODO: add version check
