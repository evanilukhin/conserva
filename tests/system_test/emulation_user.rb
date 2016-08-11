require 'rest-client'
require 'figaro'
unless Figaro.application.environment
  Figaro.application =
      Figaro::Application.new(environment: ENV['SINATRA_ENV'], path: "../../config/application.yml")
  Figaro.load
end
require "#{ENV['root']}/config/common_requirement"

def one_user (input_filename, out_extension)
  start_time = Time.now

  input_extension = File.extname("#{ENV['root']}/test_files/#{input_filename}")[1..-1]
  begin
    response = RestClient.post "http://#{ENV['address']}/api/v1/task",
                               input_extension: input_extension,
                               output_extension: out_extension,
                               api_key: ENV['token'],
                               file: File.new("#{ENV['root']}/test_files/#{input_filename}", 'rb')
    if JSON.parse(response)['id']
      task_id = JSON.parse(response)['id']
      puts "Task #{task_id} successful created."
      succ_finished = false
      3000.times do
        begin
          response = RestClient.get "http://#{ENV['address']}/api/v1/task/#{task_id}", {params: {api_key: ENV['token']}}
          state_task = JSON.parse(response)['state']
          if state_task == ConvertState::FINISHED
            succ_finished = true
            break
          end
        rescue  RestClient::ExceptionWithResponse, RestClient::RequestFailed => e
          puts "Bad request id: #{task_id unless task_id.nil?} #{[e.response.code,
                                                                  e.response.cookies,
                                                                  e.response.headers].join("\n")}"
          break

        end
        sleep 0.5
      end

      if succ_finished
        File.open("#{ENV['root']}/tests/download/#{File.basename(input_filename, ".*")}_#{task_id}.#{out_extension}", 'w') do |f|
          RestClient.get "http://#{ENV['address']}/api/v1/task/#{task_id}/download", {params: {api_key: ENV['token']}} do |str|
            f.write str
          end
        end
        puts "Task #{task_id} successful downloaded."
      else
        puts 'Conversation was failed.'
      end
    else
      puts 'Result does not exists.'
    end
  rescue => e
    puts "Bad request: #{e}"
  end

  end_time = Time.now
  (end_time-start_time).to_f
end

5.times do
  Process.fork do
    puts one_user('test_1.odt', 'pdf')
  end
  Process.fork do
    puts one_user('test_2.doc', 'pdf')
  end
  Process.fork do
    puts one_user('test_3.txt', 'pdf')
  end
  Process.fork do
    puts one_user('test_4.jpg', 'bmp')
  end
end

Process.waitall