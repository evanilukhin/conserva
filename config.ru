require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'phusion_passenger'
require 'fileutils'
require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: "development", path: "config/application.yml")
  Figaro.load
end
require_relative 'config/common_requirement'
require_relative 'api/convert_service_api'

run ConvertServiceApi