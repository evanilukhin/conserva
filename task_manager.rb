Dir.chdir ENV['root']
require_relative 'config/common_requirement'
task_mgr_logger = Logger.new('log/task_mgr.log')

# отбор модулей способных в данный момент сконвертировать задачу
# @todo а может в некое подобие хелпера вынести?
def modules_for_task task, registered_modules
  modules = []
  registered_modules.each do |reg_mod|
    if reg_mod.valid_combinations[:from].include?(task.input_extension) &&
        reg_mod.valid_combinations[:to].include?(task.output_extension)
      modules << reg_mod
    end
  end
  modules
end

mutex = ProcessShared::Mutex.new
launched_modules = Hash.new

loop do
  unconverted_tasks = ConvertTask.filter(state: ConvertState::RECEIVED).all
  convert_modules = ConvertModulesLoader::ConvertModule.modules

  prepared_tasks = unconverted_tasks.inject([]) do |prepared_tasks, task|
    modules = modules_for_task(task, convert_modules)
    if modules.any?
      prepared_tasks << [task, modules]
    else
      task.update(errors: I18n.t(:modules_not_exist, scope: 'convert_task.error'))
      task_mgr_logger.error I18n.t(:modules_not_exist,
                                   scope: 'task_manager_logger.error',
                                   input_extension: task.input_extension,
                                   output_extension: task.output_extension,
                                   id: task.id)
    end
  end

# пока запускаем первый попавшийся не занятый модуль из доступных для задачи
# в идеале, "равномерное" раскидывание задач по модулям
# с учётом времени поступления задачи
  prepared_tasks.to_h.each do |task, modules|
    conv_module = modules.first
    mutex.synchronize do
      unless launched_modules.has_key? conv_module
        launched_modules[conv_module] = ProcessShared::SharedMemory.new(:int)
        launched_modules[conv_module].put_int(0, 0)
      end
      value = launched_modules[conv_module].get_int(0)
      if value < conv_module.max_launched_modules
        launched_modules[conv_module].put_int(0, value + 1)
        task.update(state: ConvertState::PROCEED)
        process = Process.fork do
          files_dir = ENV['file_storage']
          input_filename = task.received_file_path
          result_filename = input_filename.gsub(File.extname(input_filename), "") << ".#{task.output_extension}"

          convert_options = {output_extension: task.output_extension,
                             output_dir: files_dir,
                             source_path: "#{files_dir}/#{input_filename}",
                             destination_path: "#{files_dir}/#{result_filename}"
          }

          if conv_module.run(convert_options)
            task_mgr_logger.info I18n.t(:success_convert,
                                        scope: 'task_manager_logger.info',
                                        id: task.id)
            task.updated_at = Time.now
            task.state = ConvertState::FINISHED
            task.converted_file_path = result_filename
            task.finished_at = Time.now
            task.save # если не проходит валидацию - падает, обернуть как исключение или сделать проверку перед сохранением
          else
            task.update(state: ConvertState::ERROR)
            task_mgr_logger.error I18n.t(:fail_convert,
                                         scope: 'task_manager_logger.error',
                                         id: task.id)
          end
          mutex.synchronize do
            value = launched_modules[conv_module].get_int(0)
            launched_modules[conv_module].put_int(0, value - 1)
          end
        end
        Process.detach process
      end
    end
  end
  sleep 1
end

