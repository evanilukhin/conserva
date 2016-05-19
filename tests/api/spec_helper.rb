require 'figaro'
puts Dir.pwd
Figaro.application =
    Figaro::Application.new(environment: 'test', path: "#{File.dirname(__FILE__)}/../../config/application.yml")
Figaro.load
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/namespace'
require 'json'
require 'fileutils'
require "#{ENV['root']}/config/common_requirement"
require 'rack/test'
require 'rspec'
require "#{ENV['root']}/api/convert_service_api"
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'