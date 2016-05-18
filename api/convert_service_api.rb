class ConvertServiceApi < Sinatra::Base
  register Sinatra::Reloader
  register Sinatra::Namespace
  # Запрос получения состояния задачи

  namespace '/api' do
    namespace '/v1' do
      get '/task/:id' do
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
      post '/task' do
        content_type :json
        # валидация запроса
        if api_key
          # сохранение файла
          tempfile_path = new_task_params[:tempfile].path
          file_name = "#{(Time.now.to_f*1000).ceil}_#{new_task_params[:filename]}"
          FileUtils.mv(tempfile_path, "#{ENV['file_storage']}/#{file_name}")

          # создание задачи
          DB.transaction do
            begin
              task = ConvertTask.create do |ct|
                ct.source_file = file_name
                ct.input_extension = new_task_params[:input_extension]
                ct.output_extension = new_task_params[:output_extension]
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
      get '/task/:id/download' do
        if authorized_task.state == ConvertState::FINISHED
          file_name = authorized_task.converted_file
          send_file "#{ENV['file_storage']}/#{file_name}", filename: file_name
        else
          status 202
        end
      end

      # Запрос на удаление добавленной задачи
      delete '/task/:id' do
        if authorized_task.state != ConvertState::PROCEED
          FileUtils.rm_f "#{ENV['file_storage']}/#{authorized_task.source_file}"
          FileUtils.rm_f "#{ENV['file_storage']}/#{authorized_task.converted_file}"
          authorized_task.delete
          status 200
        else
          halt 423 # Если задача обрабатывается мы ничего не можем сделать (код Locked)
        end
      end

      helpers do
        def api_key
          params[:api_key] && ApiKey.find(id: params[:api_key]) ? ApiKey.find(id: params[:api_key]) : halt(401)
        end

        def unauthorized_task
          ConvertTask.find(id: params[:id]) || halt(404)
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
    end
  end

end
