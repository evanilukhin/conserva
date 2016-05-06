require 'daemons'
require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: "development", path: "#{File.dirname(__FILE__)}/config/application.yml")
  Figaro.load
end
require "#{ENV['root']}/config/common_requirement"

Daemons.run_proc(
    'task_manager',
    :dir_mode => :script,
    :dir => ENV['root'],
    :log_output => true
) { exec "ruby #{ENV['root']}/task_manager.rb" }
