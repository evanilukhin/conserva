require 'rubygems'
require 'daemons'

require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: "development", path: "#{File.dirname(__FILE__)}/config/application.yml")
  Figaro.load
end
file = "#{ENV['root']}/task_manager.rb"

Daemons.run_proc(
    'task_manager', # name of daemon
    :dir_mode => :script,
    :dir => ENV['root'], # directory where pid file will be stored
    #  :backtrace => true,
    #  :monitor => true,
    :log_output => true
) { exec "ruby #{file}" }
