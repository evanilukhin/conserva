class ConvertServiceApi < Sinatra::Base
  register Sinatra::Namespace
  # Запрос получения состояния задачи


  namespace '/api' do
    namespace '/v1' do

      # @todo добавить валидацию параметра идентификатора
      # @todo ограничить количество возвращаемых параметров
      get '/task/:id' do
        content_type :json
        case authorized_task.state
          when ConvertState::ERROR
            status 500
            {message: 'Sorry, conversation was failed, please resend file.'}.to_json
          else
            status 200
        end
        authorized_task.to_json(except: [:id, :errors, :api_key_id])
      end

      # Запрос на конвертацию
      post '/task' do
        content_type :json
        # валидация запроса
        if api_key
          # сохранение файла
          tempfile_path = new_task_params[:tempfile].path
          file_name = "#{(Time.now.to_f*1000).ceil}_#{new_task_params[:filename]}".tr(' ','')
          new_source_file_path = "#{ENV['file_storage']}/#{file_name}"
          FileUtils.mv(tempfile_path, new_source_file_path)
          # создание задачи
          DB.transaction do
            begin
              task = ConvertTask.create do |ct|
                ct.source_file = file_name
                ct.input_extension = new_task_params[:input_extension]
                ct.output_extension = new_task_params[:output_extension]
                ct.created_at = Time.now
                ct.state = ConvertState::RECEIVED
                ct.source_file_sha256 = Digest::SHA256.file(new_source_file_path).hexdigest
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
        task = authorized_task
        if task.state == ConvertState::FINISHED
          file_name = task.converted_file
          task.downloads_count += 1
          task.last_download_time = Time.now
          task.save
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

      # Запрос на получение возможных преобразований файлов
      get '/convert_combinations' do
        content_type :json
        status 200
        valid_combinations.to_json
      end


      helpers do

        # список возможных преобразований файлов
        def valid_combinations
          ConvertModulesLoader::ConvertModule.valid_combinations
        end

        def api_key
          params[:api_key] && ApiKey.find(uuid: params[:api_key]) ? ApiKey.find(uuid: params[:api_key]) : halt(401)
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
              params[:file][:filename] &&
              valid_combinations.include?([params[:input_extension],
                                           params[:output_extension]])
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
