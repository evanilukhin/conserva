class ConvertServiceApi < Sinatra::Base
  register Sinatra::Reloader
  # Запрос получения состояния задачи
  get '/state/:id_task' do
    content_type :json
    convert_task = ConvertTask.find(id: params[:id_task])
    if convert_task
      case convert_task.state
        when ConvertState::ERROR
          status 500
          {message: 'Sorry, conversation was failed.'}.to_json
        else
          status 200
      end
      convert_task.to_json
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
      tempfile_path = params[:file][:tempfile].path
      file_name = "#{Time.now.strftime("%Y_%m_%d-%T")}_#{params[:file][:filename]}"
      FileUtils.mv(tempfile_path, "#{ENV['file_storage']}/#{file_name}")


      # создание задачи
      DB.transaction do
        begin
          task = ConvertTask.create do |ct|
            ct.source_file = file_name
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
        task.refresh
        {id: task.id}.to_json
      end

    else
      status 406
    end

  end

  # Запрос на получение готового файла
  get '/get_converted_file/:id_task' do
    task = ConvertTask.find(id: params[:id_task])
    if task
      if task.state == ConvertState::FINISHED
        file_name = task.converted_file
        send_file "#{ENV['file_storage']}/#{file_name}", filename: file_name
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

  def valid_request? request

  end
end
