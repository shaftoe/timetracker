Gem::Specification.new do |s|
  s.name        = 'timetracker'
  s.version     = '0.1.0'
  s.date        = '2012-09-30'
  s.summary     = "TimeTracker"
  s.description = "A simple CLI time tracker"
  s.authors     = ["Alexander Fortin"]
  s.email       = 'alexander.fortin@gmail.com'
  s.files       = ["lib/timetracker.rb", "lib/timetracker/datastore.rb"]
  s.executables << 'timetracker'
  s.homepage    = 'http://test/'
  s.add_runtime_dependency "sqlite3", [">= 1.3.6"]
end