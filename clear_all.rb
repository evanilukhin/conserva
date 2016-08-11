require 'sequel'
require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: ENV['SINATRA_ENV'], path: "#{File.dirname(__FILE__)}/config/application.yml")
  Figaro.load
end
Dir["#{ENV['file_storage']}/*"].each {|file| File.delete file }
Dir["#{ENV['root']}/tests/download/*"].each {|file| File.delete file }
DB = Sequel.connect(ENV['db'])
DB[:convert_tasks].delete