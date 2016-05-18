class ConvertServiceApi < Sinatra::Base
  register Sinatra::Reloader
  # Запрос получения состояния задачи
  helpers do
    def api_key
      params[:api_key] && ApiKey.find(id: params[:api_key]) ? ApiKey.find(id: params[:api_key]) : halt(401)
    end

    def unauthorized_task
      ConvertTask.find(id: params[:id_task]) || halt(404)
    end

    def authorized_task
      unauthorized_task.api_key == api_key ? unauthorized_task : halt(403)
    end

    def new_task_params
      if params[:input_extension] &&
          params[:output_extension] &&
          params[:file] &&
          params[:file][:tempfile] &&
          params[:file][:filename]
        {
            input_extension: params[:input_extension],
            output_extension: params[:output_extension],
            filename: params[:file][:filename],
            tempfile: params[:file][:tempfile]
        }
      else
        halt 406
      end
    end
  end

  get '/state/:id_task' do
    content_type :json
    case authorized_task.state
      when ConvertState::ERROR
        status 500
        {message: 'Sorry, conversation was failed.'}.to_json
      else
        status 200
    end
    authorized_task.to_json
  end

  # Запрос на конвертацию
  post '/convert_file' do
    content_type :json
    # валидация запроса
    if api_key
      # сохранение файла
      tempfile_path = new_task_params[:tempfile].path
      file_name = "#{Time.now.strftime("%Y_%m_%d-%T")}_#{new_task_params[:filename]}"
      FileUtils.mv(tempfile_path, "#{ENV['file_storage']}/#{file_name}")

      # создание задачи
      DB.transaction do
        begin
          task = ConvertTask.create do |ct|
            ct.source_file = file_name
            ct.input_extension = new_task_params[:input_extension]
            ct.output_extension = new_task_params[:input_extension]
            ct.created_at = Time.now
            ct.state = ConvertState::RECEIVED
            ct.api_key = api_key
          end
        rescue Sequel::ValidationFailed => e
          halt 422, {message: e.message}.to_json
        end
        # ответ
        status 201
        task.refresh
        {id: task.id}.to_json
      end
    end

  end

  # Запрос на получение готового файла
  get '/get_converted_file/:id_task' do
    if authorized_task.state == ConvertState::FINISHED
      file_name = authorized_task.converted_file
      send_file "#{ENV['file_storage']}/#{file_name}", filename: file_name
    else
      status 202
    end
  end

end
