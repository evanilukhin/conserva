require 'figaro'
require 'sequel'
Figaro.application =
    Figaro::Application.new(environment: "development", path: "config/application.yml")
Figaro.load
DB = Sequel.connect(ENV['db'])
require "#{ENV['root']}/entities/auth_token"


desc "Generate unique token"
task :create_token, [:comment] do |t, args|
  args.with_defaults(comment: "")
  uuid = SecureRandom.uuid
  AuthToken.create do |auth_token|
    auth_token.uuid = uuid
    auth_token.comment = args.comment
  end
  puts uuid
end