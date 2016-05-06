require 'open3'
class BaseConverter
  class << self
    def run_command(launch_string)
      o, s = Open3.capture2e launch_string
      result_handler o, s
    end

    # значение таймаута в секундах
    def timeout_time
      60
    end

    def max_launched_modules
      1
    end

    def logger
      @@logger ||= Logger.new("#{ENV['root']}/log/task_mgr.log")
    end

    # метод обрабатывает результаты запуска модуля и отвечает за  логирование
    # возвращает true или false в зависимости от успешности конвертации
    def result_handler output, state
      if state.exitstatus == 0
        logger.info output unless output.empty?
        true
      else
        logger.error output
        false
      end
    end
  end
end
