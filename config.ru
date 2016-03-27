require 'sinatra'
require 'sinatra/reloader'
require 'rubygems'
require 'sequel'
require 'awesome_print'
require 'json'
DB = Sequel.connect('postgres://xenomorf:ananas@localhost:5432/xenomorf')
require_relative 'entities/convert_task'
require_relative 'api/api'
run MyApp
