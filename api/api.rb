require 'rubygems'
require 'sinatra'
require "sequel"
require 'json'

# Запрос получения состояния задачи
get '/state/:id_task' do
  content_type :json
  {message: "Returned state with id #{params[:id_task]}"}.to_json
end

# Запрос на конвертацию
post '/convert_file' do
  tempfile = params['file'][:tempfile]
  filename = params['file'][:filename]
  File.open("#{Time.now.strftime("%Y_%m_%d-%T")}_#{filename}",'wb') do |file|
    file.write tempfile.read
  end
  response.body = {message: "Task  successful created \n"}.to_json
end

# Запрос на получение готового файла
get '/get_converted_file/:id_task' do
  "Converted file from task with id #{params[:id_task]}"
end
