require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/namespace'
require 'json'
require 'phusion_passenger'
require 'fileutils'
require 'figaro'

environment = ENV['SINATRA_ENV'] || 'development'
Figaro.application =
      Figaro::Application.new(environment: environment, path: "config/environment.yml")
Figaro.load


require "#{ENV['root']}/config/common_requirement"
require "#{ENV['root']}/api/convert_service_api"

if environment.eql?('production')
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