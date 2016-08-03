require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/namespace'
require 'json'
require 'phusion_passenger'
require 'fileutils'
require 'figaro'

Figaro.application =
    Figaro::Application.new(path: "config/environment.yml")
Figaro.load

Figaro.application =
      Figaro::Application.new(environment: ENV['environment'], path: "config/database.yml")
Figaro.load


require "#{ENV['root']}/config/common_requirement"
require "#{ENV['root']}/api/convert_service_api"
################################################################################
# Код для  PhusionPassenger в режиме smart spawn
# для использования других серверов закомментировать фрагмент

# DB.disconnect
#
# if defined?(PhusionPassenger)
#   PhusionPassenger.on_event(:starting_worker_process) do |forked|
#     if forked
#       DB = Sequel.connect(ENV['db'])
#     else
#       # We're in direct spawning mode. We don't need to do anything.
#     end
#   end
# end

##################################################################################

run ConvertServiceApi