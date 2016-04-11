require 'resque/tasks'
require './worker'

task :add_events do
  Worker.add_events(ENV["INTEGRATION_ID"], (1..100))
end
