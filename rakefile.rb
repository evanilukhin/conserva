require 'figaro'
require 'sequel'
require 'securerandom'
Figaro.application =
    Figaro::Application.new(environment: 'development', path: 'config/application.yml')
Figaro.load
DB = Sequel.connect(ENV['db'])
require "#{ENV['root']}/entities/api_key"


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