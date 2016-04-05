require 'sequel'
require 'awesome_print'
# DB = Sequel.connect('postgres://xenomorf:ananas@localhost:5432/xenomorf')
DB = Sequel.connect('sqlite://../conserv.db')

require_relative '../entities/convert_task'
require_relative 'convert_modules_loader'

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

unconverted_tasks = ConvertTask.exclude(state: ['finished']).all # @todo заменить статус на объект перечислямого типа
convert_modules = ConvertModulesLoader::ConvertModule.modules

prepared_tasks = {}
unconverted_tasks.each do |task|
  prepared_tasks[task] = modules_for_task(task, convert_modules)
end

# пока запускаем первый попавшийся не занятый модуль из доступных для задачи
# в идеале, "равномерное" раскидывание задач по модулям
# с учётом времени поступления задачи
prepared_tasks.each do |task, modules|
  if modules.empty?
    # @todo сюда же добавить логирование уровня где-то Error
    task.errors = "Отсутсвуют необходимые модули конвертации"
    task.save
  else

  end
end

