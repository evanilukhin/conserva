require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'sequel'
require 'fileutils'
require 'i18n'
I18n.enforce_available_locales = true
I18n.load_path = Dir['localization/*.yml']
I18n.locale = :ru
DB = Sequel.connect('sqlite://conserv.db')

require_relative 'entities/convert_task'
require_relative 'entities/convert_state'
require_relative 'api/convert_service_api'


run ConvertServiceApi