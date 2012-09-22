#!/usr/bin/ruby -w
# -*- coding: utf-8 -*-
require 'sqlite3'

class TTDataStore

  def initialize dbname=".timetrackerdb", timezone=0, version=0.0, verbosity=0
    @dbname = dbname
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
    @db.execute 'INSERT INTO system ( timezone, version, verbosity ) VALUES ( %s, %s, %s )' %
      [timezone, version, verbosity]
  end

  def setcurrent issueid
    oldcurrent = @db.execute 'SELECT current, latest FROM system'
    @db.execute "UPDATE system SET current = '%d', latest = '%s'" %
      [issueid, oldcurrent[0][0] != '' ? oldcurrent[0][0] : oldcurrent[0][1]]
  end

  public
  def startnew issuename, notes=''
    @db.execute "INSERT INTO timesheet ( name, notes ) VALUES ( '%s', '%s' )" %
      [issuename, notes]
    latest = @db.execute "SELECT id FROM timesheet ORDER BY id DESC LIMIT 1"
    setcurrent latest[0][0]
  end

  def stoprunning
    running = @db.execute "SELECT current FROM system"
    unless running[0][0] == ''
      @db.execute "UPDATE timesheet set tstop = datetime('now') WHERE id = %d" % running[0][0]
      @db.execute "UPDATE system SET current = '', latest = '%d'" % running[0][0]
    else
      p "Not tracking"
    end
  end
end  # End DataStore class


class TimeTracker

  def initialize
    @db = TTDataStore.new
  end

  def start
    @db.startnew ARGV[1]
  end

  def stop
    @db.stoprunning
  end

end



if ARGV[0] == 'start'
  tt = TimeTracker.new
  tt.start
end
if ARGV[0] == 'stop'
  tt = TimeTracker.new
  tt.stop
end
