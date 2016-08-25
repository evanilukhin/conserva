#!/usr/bin/env ruby
#
# Этот файл нужен для загрузки демона конвертации из консоли. Systemd натравливать нужно на task_manager.rb
#

require 'daemons'
require 'figaro'
require_relative 'config/environment'

require "#{ENV['root']}/config/common_requirement"

Daemons.run_proc(
    'task_manager',
    :dir_mode => :script,
    :dir => ENV['root'],
    :log_output => true
) { exec "ruby #{ENV['root']}/task_manager.rb" }
