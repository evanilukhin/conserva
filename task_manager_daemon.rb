#!/usr/bin/env ruby

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
