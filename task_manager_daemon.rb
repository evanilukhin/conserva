require 'daemons'
require 'figaro'
Figaro.application =
    Figaro::Application.new(path: "config/environment.yml")
Figaro.load
Figaro.application =
    Figaro::Application.new(environment: ENV['environment'], path: "config/database.yml")
Figaro.load

require "#{ENV['root']}/config/common_requirement"

Daemons.run_proc(
    'task_manager',
    :dir_mode => :script,
    :dir => ENV['root'],
    :log_output => true
) { exec "ruby #{ENV['root']}/task_manager.rb" }
