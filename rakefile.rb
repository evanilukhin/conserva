require 'figaro'
require 'sequel'
require 'securerandom'

require_relative 'config/environment'

DB = Sequel.connect(ENV['db'])
require "#{ENV['root']}/entities/api_key"
require "#{ENV['root']}/entities/convert_task"

namespace :task_cleaner do
  desc 'Clear downloaded files. (Run every 1-10 minutes)'
  task :downloaded do
    clear_time = Time.now-ENV['downloaded_tasks_store_time'].to_i
    cleanable_tasks =
        ConvertTask.filter{(downloads_count > 0) & (last_download_time < clear_time) }
    count_cleanable = cleanable_tasks.count
    cleanable_tasks.each do |task|
      FileUtils.rm_f "#{ENV['file_storage']}/#{task.source_file}"
      FileUtils.rm_f "#{ENV['file_storage']}/#{task.converted_file}"
      task.delete
    end
    puts "Success. Cleaned #{count_cleanable} tasks."
  end

  desc 'Clear outdated files. (Run every 3-10 days)'
  task :outdated do
    clear_time = Time.now-ENV['tasks_store_days'].to_i*24*3600
    count_cleanable = cleanable_tasks.count
    cleanable_tasks =
        ConvertTask.filter{created_at < clear_time}
    cleanable_tasks.each do |task|
      FileUtils.rm_f "#{ENV['file_storage']}/#{task.source_file}"
      FileUtils.rm_f "#{ENV['file_storage']}/#{task.converted_file}"
      task.delete
    end
    puts "Success. Cleaned #{count_cleanable} tasks."
  end
end

namespace :db do
  # examples
  # 1) rake db:migrate - migrate to last version
  # 2) rake db:migrate[42] - migrate to concrete version
  desc 'Run migrations'
  task :migrate, [:version] do |t, args|
    Sequel.extension :migration
    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(DB, 'migrations', target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(DB, 'migrations')
    end
  end
end

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