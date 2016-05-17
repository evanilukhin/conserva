require 'figaro'
require 'sequel'
require 'securerandom'
Figaro.application =
    Figaro::Application.new(environment: "development", path: "config/application.yml")
Figaro.load
DB = Sequel.connect(ENV['db'])
require "#{ENV['root']}/entities/api_key"


desc "Generate unique token"
task :create_token, [:comment] do |t, args|
  args.with_defaults(comment: "")
  uuid = SecureRandom.uuid
  ApiKey.create do |auth_token|
    auth_token.id = uuid
    auth_token.comment = args.comment
  end
  puts uuid
end