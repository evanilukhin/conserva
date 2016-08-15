require 'daemons'
require 'figaro'

Figaro.application =
    Figaro::Application.new(environment: ENV['SINATRA_ENV'] || 'development', path: "config/environment.yml")
Figaro.load

require "#{ENV['root']}/config/common_requirement"

Daemons.run_proc(
    'task_manager',
    :dir_mode => :script,
    :dir => ENV['root'],
    :log_output => true
) { exec "ruby #{ENV['root']}/task_manager.rb" }
