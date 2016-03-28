class ConvertServiceApi < Sinatra::Base
  register Sinatra::Reloader
  # Запрос получения состояния задачи
  get '/state/:id_task' do
    content_type :json
    convert_task = ConvertTask.find(id: params[:id_task])
    if convert_task
      {message: "Returned state  #{ConvertTask.find(id: params[:id_task]).to_hash}"}.to_json
    else
      status 404
    end
  end

  # Запрос на конвертацию
  post '/convert_file' do
    # валидация запроса
    input_extension = params[:input_extension]
    output_extension = params[:output_extension]
    # сохранение файла

    tempfile = params[:tempfile]
    filename = params[:filename]

    File.open("temp_files/#{Time.now.strftime("%Y_%m_%d-%T")}_#{filename}", 'wb') do |file|
      file.write tempfile
    end

    # создание задачи
    ConvertTask.create do |ct|
      ct.gotten_file_path = filename
      ct.input_extension = input_extension
      ct.output_extension = output_extension
      ct.state = 'getted'
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
