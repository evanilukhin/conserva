require 'sequel'
require 'logger'
require 'i18n'

I18n.enforce_available_locales = true
I18n.load_path = Dir['localization/*.yml']
I18n.locale = :en

task_mgr_logger = Logger.new('log/task_mgr.log')
DB = Sequel.connect('sqlite://conserv.db')

require_relative 'entities/convert_task'
require_relative 'entities/convert_state'
require_relative 'modules/convert_modules_loader'

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

unconverted_tasks = ConvertTask.filter(state: ConvertState::RECEIVED).all
convert_modules = ConvertModulesLoader::ConvertModule.modules
launched_modules = Hash[convert_modules.map { |conv_module| [conv_module, 0] }]

prepared_tasks = {}
unconverted_tasks.each do |task|
  prepared_tasks[task] = modules_for_task(task, convert_modules)
end

# пока запускаем первый попавшийся не занятый модуль из доступных для задачи
# в идеале, "равномерное" раскидывание задач по модулям
# с учётом времени поступления задачи
prepared_tasks.each do |task, modules|
  if modules.empty?
    task.update(errors: I18n.t(:modules_not_exist, scope: 'convert_task.error'))
    task_mgr_logger.error I18n.t(:modules_not_exist,
                                 scope: 'task_manager_logger.error',
                                 input_extension: task.input_extension,
                                 output_extension: task.output_extension,
                                 id: task.id )
  else
    conv_module = modules.first
    if launched_modules[conv_module] < conv_module.max_launched_modules
      launched_modules[conv_module] += 1
      task.update(state:ConvertState::PROCEED)
      Process.fork do
        files_dir = 'temp_files/'
        input_filename = File.split(task.received_file_path).last
        result_filename = input_filename.gsub(File.extname(input_filename), "") << ".#{task.output_extension}"

        convert_options = {output_extension: task.output_extension,
                           output_dir: files_dir,
                           source_path: task.received_file_path,
                           destination_path: "#{files_dir}#{result_filename}"
        }

        if conv_module.run(convert_options)
          task_mgr_logger.info I18n.t(:success_convert,
                                      scope: 'task_manager_logger.info',
                                      id: task.id)
          task.updated_at = Time.now
          task.state = ConvertState::FINISHED
          task.converted_file_path = "#{files_dir}#{result_filename}"
          task.finished_at = Time.now
          task.save
        else
          task.update(state: ConvertState::ERROR)
          task_mgr_logger.error I18n.t(:fail_convert,
                                       scope: 'task_manager_logger.error',
                                       id: task.id)
        end
      end
    end
  end
end

