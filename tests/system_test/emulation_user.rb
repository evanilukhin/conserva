require 'rest-client'
require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: "test", path: "../../config/application.yml")
  Figaro.load
end
require "#{ENV['root']}/config/common_requirement"

def one_user (input_filename, out_extension)
  start_time = Time.now
  input_extension = File.extname("#{ENV['root']}/test_files/#{input_filename}")[1..-1]

  begin
    response = RestClient.post 'http://localhost:9292/convert_file',
                               input_extension: input_extension,
                               output_extension: out_extension,
                               file: File.new("#{ENV['root']}/test_files/#{input_filename}", 'rb')
  rescue => e
    puts "Bad request #{e.response}"
  end

  task_id = JSON.parse(response)['id']
  puts "Task #{task_id} successful created."
  result = 1000000.times do
    begin
      response = RestClient.get "http://localhost:9292/state/#{task_id}"
      state_task = JSON.parse(response)['state']
      break if state_task == ConvertState::FINISHED
    rescue => e
      puts "Bad request #{e}"
      break
    end
    sleep 0.1
  end

  if result.nil?
    File.open("#{ENV['root']}/download/file_#{task_id}.doc", 'w') do |f|
      RestClient.get "http://localhost:9292/get_converted_file/#{task_id}" do |str|
        f.write str
      end
    end
    puts "Task #{task_id} successful downloaded."
  else
    puts 'Time out!'
  end
  end_time = Time.now

  (end_time-start_time).to_f
end

20.times do
  Process.fork do
    puts one_user('test_1.odt','pdf')
  end
  Process.fork do
    puts one_user('test_2.doc','pdf')
  end
  Process.fork do
    puts one_user('test_3.txt','pdf')
  end
  Process.fork do
    puts one_user('test_4.jpg','pdf')
  end
end

Process.waitall