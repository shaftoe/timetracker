require 'sqlite3'


class DataStore

  def initialize dbname=".timetracker.db", version=0.1
    @dbname = dbname
    if FileTest.zero?(dbname) or not FileTest.file?(dbname)
      @db = SQLite3::Database.new( dbname )
      createschema
      init(version)
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
    );
    SQL

    @db.execute <<-SQL
    CREATE TABLE timesheet (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name,
      tstart DEFAULT CURRENT_TIMESTAMP,
      tstop,
      synced DEFAULT 'false',
      notes
    );
    SQL
  end

  def init version
    @db.execute 'INSERT INTO system ( timezone, version, verbosity ) VALUES ( 2, %s, 0 );' % version
  end

end # End db class


db = DataStore.new
