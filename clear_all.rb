require 'sequel'
require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: "development", path: "#{File.dirname(__FILE__)}/config/application.yml")
  Figaro.load
end
Dir["#{ENV['file_storage']}/*"].each {|file| File.delete file }
DB = Sequel.connect(ENV['db'])
DB[:convert_tasks].delete