require 'resque/tasks'
require './worker'

task :add_event do
  Worker.add_event(ENV["INTEGRATION_ID"], ENV["EVENT_ID"])
end
