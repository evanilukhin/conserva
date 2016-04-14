class ConvertServiceApi < Sinatra::Base
  register Sinatra::Reloader
  # Запрос получения состояния задачи
  get '/state/:id_task' do
    content_type :json
    convert_task = ConvertTask.find(id: params[:id_task])
    if convert_task
      convert_task.to_hash.to_json
    else
      status 404
    end
  end

  # Запрос на конвертацию
  post '/convert_file' do
    content_type :json
    # валидация запроса
    if validate_params params

      input_extension = params[:input_extension]
      output_extension = params[:output_extension]
      # сохранение файла
      tempfile = params[:file][:tempfile]
      file_path = "temp_files/#{Time.now.strftime("%Y_%m_%d-%T")}_#{params[:file][:filename]}"
      File.open(file_path, 'wb') do |file|
        file.write tempfile.read
      end

      # создание задачи
      begin
        task = ConvertTask.create do |ct|
          ct.received_file_path = file_path # @todo заменить имя на source_file
          ct.input_extension = input_extension
          ct.output_extension = output_extension
          ct.created_at = Time.now
          ct.state = ConvertState::RECEIVED
        end
      rescue Sequel::ValidationFailed => e
        halt 422, {message: e.message}.to_json
      end
      # ответ
      status 201
      {id: task.id}.to_json
    else
      status 406
    end

  end

  # Запрос на получение готового файла
  get '/get_converted_file/:id_task' do
    task = ConvertTask.find(id: params[:id_task])
    if task
      if task.state == ConvertState::FINISHED
        file_path = task.converted_file_path
        send_file file_path, filename: file_path.split('/').last
      else
        status 202
      end
    else
      status 404
    end
  end

  private
  def validate_params params
    if params[:input_extension] &&
        params[:output_extension] &&
        params[:file] &&
        params[:file][:tempfile] &&
        params[:file][:filename]
      true
    else
      false
    end
  end
end
