Gem::Specification.new do |s|
  s.name        = 'ttrack'
  s.version     = '0.2.1'
  s.date        = '2012-10-15'
  s.summary     = "Time Tracker"
  s.description = "A simple CLI time tracker"
  s.authors     = ["Alexander Fortin"]
  s.email       = 'alexander.fortin@gmail.com'
  s.files       = ["lib/ttrack.rb", "lib/ttrack/datastore.rb"]
  s.executables << 'ttrack'
  s.homepage    = 'https://rubygems.org/gems/ttrack'
  s.add_runtime_dependency "sqlite3", [">= 1.3.6"]
end
