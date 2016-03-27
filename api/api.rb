class MyApp < Sinatra::Base
  register Sinatra::Reloader
  # Запрос получения состояния задачи
  get '/state/:id_task' do
    content_type :json
    {message: "Returned state  #{ConvertTask.find(id: params[:id_task]).to_s}"}.to_json
  end

  # Запрос на конвертацию
  post '/convert_file' do
    # валидация запроса

    # сохранение файла
    tempfile = params.first[1][:tempfile]
    filename = params.first[1][:filename]
    File.open("temp_files/#{Time.now.strftime("%Y_%m_%d-%T")}_#{filename}", 'wb') do |file|
      file.write tempfile.read
    end

    # создание задачи
    ConvertTask.create do |ct|
      ct.gotten_file_path = filename
      ct.state = 'get'
    end

    # ответ
    response.body = {message: "Task  successful created \n"}.to_json
  end

  # Запрос на получение готового файла
  get '/get_converted_file/:id_task' do
    send_file '../README.md', filename: 'README'
    "Converted file from task with id #{params[:id_task]}"

  end
end
