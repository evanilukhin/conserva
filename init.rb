require 'rubygems'
require 'sequel'
require 'awesome_print'
DB = Sequel.connect('postgres://xenomorf:ananas@localhost:5432/xenomorf')
require_relative 'convert_task'