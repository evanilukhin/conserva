require 'rubygems'
require 'daemons'

pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/task_manager.rb'

Daemons.run_proc(
    'task_manager', # name of daemon
    :dir_mode => :script,
    :dir => pwd, # directory where pid file will be stored
    #  :backtrace => true,
    #  :monitor => true,
    :log_output => true
) do
  exec "ruby #{file}"
end