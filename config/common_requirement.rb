require 'sequel'
require 'logger'
require 'i18n'
require 'process_shared'
I18n.enforce_available_locales = true
I18n.load_path = Dir["#{ENV['root']}/localization/*.yml"]
I18n.locale = :en
DB ||= Sequel.connect(ENV['db'])
Sequel::Model.plugin :json_serializer
require "#{ENV['root']}/entities/convert_task"
require "#{ENV['root']}/entities/convert_state"
require "#{ENV['root']}/converters/convert_modules_loader"