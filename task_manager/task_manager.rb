require 'sequel'
require 'awesome_print'
# DB = Sequel.connect('postgres://xenomorf:ananas@localhost:5432/xenomorf')
DB = Sequel.connect('sqlite://../conserv.db')

require_relative '../entities/convert_task'
require_relative 'convert_modules_loader'
unconverted_tasks = ConvertTask.exclude(state: ['finished']).all # @todo заменить статус на объект перечислямого типа
unconverted_tasks.each do |task|
  # ConvertModules.modules.first - заглушка пока не реализован автоматический выбор модуля конвертации для задачи
  module_valid_combinations = ConvertModulesLoader::ConvertModule.modules.first.valid_combinations
  if module_valid_combinations[:from].include?(task.input_extension) &&
      module_valid_combinations[:to].include?(task.output_extension)
    begin
      puts(ConvertModules.modules.first.run task)
    rescue Exception => e
      # обработка ошибки в конвертирующей программе
      puts e.message
    end
  end
end
