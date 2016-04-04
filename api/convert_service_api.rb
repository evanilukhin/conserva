class ConvertServiceApi < Sinatra::Base
  register Sinatra::Reloader
  # Запрос получения состояния задачи
  get '/state/:id_task' do
    content_type :json
    convert_task = ConvertTask.find(id: params[:id_task])
    if convert_task
      convert_task.to_hash.to_json
    else
      status 422
    end
  end

  # Запрос на конвертацию
  post '/convert_file' do
    # валидация запроса
    input_extension = params[:input_extension]
    output_extension = params[:output_extension]

    # сохранение файла
    tempfile = params[:file][:tempfile]
    file_path = "temp_files/#{Time.now.strftime("%Y_%m_%d-%T")}_#{params[:file][:filename]}"
    File.open(file_path, 'wb') do |file|
      file.write tempfile.read
    end

    # создание задачи
    ConvertTask.create do |ct|
      ct.gotten_file_path = file_path
      ct.input_extension = input_extension
      ct.output_extension = output_extension
      ct.created_at = Time.now
      ct.state = 'getted' # @todo заменить статус на объект перечислямого типа
    end

    # ответ
    response.body = {message: "Task  successful created \n"}.to_json
  end

  # Запрос на получение готового файла
  get '/get_converted_file/:id_task' do
    file_path = ConvertTask.find(id: params[:id_task]).gotten_file_path
    send_file file_path, filename: file_path.split('/').last
  end
end
