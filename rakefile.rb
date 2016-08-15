require 'figaro'
require 'sequel'
require 'securerandom'

Figaro.application =
    Figaro::Application.new(environment: ENV['SINATRA_ENV'] || 'development', path: "config/environment.yml")
Figaro.load

DB = Sequel.connect(ENV['db'])
require "#{ENV['root']}/entities/api_key"


# example: rake create_token['user_token','Token  for user User']
desc 'Generate unique token'
task :create_token, [:name, :comment] do |t, args|
  args.with_defaults(name: 'default_name', comment: '')
  existed_uuid = ApiKey.all.map(&:uuid)
  loop do
    @uuid = SecureRandom.uuid
    break unless existed_uuid.include? @uuid
  end
  ApiKey.create do |auth_token|
    auth_token.uuid = @uuid
    auth_token.name = args.name
    auth_token.comment = args.comment
  end
  puts @uuid
end
# @todo добавить задачу на смену токена пользователю, имя пользователя сделать уникальным