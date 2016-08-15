require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/namespace'
require 'json'
require 'phusion_passenger'
require 'fileutils'
require 'figaro'
require_relative 'config/environment'
require "#{ENV['root']}/config/common_requirement"
require "#{ENV['root']}/api/convert_service_api"

if ENV['SINATRA_ENV'] && ENV['SINATRA_ENV'].eql?('production')
  DB.disconnect
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      DB = Sequel.connect(ENV['db'])
    else
      # We're in direct spawning mode. We don't need to do anything.
    end
  end
end

run ConvertServiceApi