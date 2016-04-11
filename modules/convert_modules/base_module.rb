require 'open3'
module BaseConvertModule
  def run_command(launch_string)
    o, s = Open3.capture2e launch_string
    result_handler o, s
  end

  # значение таймаута в секундах
  def timeout_time
    60
  end

  # метод обрабатывает результаты запуска модуля и отвечает за  логирование
  # возвращает true или false в зависимости от успешности конвертации
  # @todo добавить запись в лог
  def result_handler output, state
    if state.exitstatus == 0
      logger.info output
      true
    else
      logger.error output
      false
    end
  end

  def logger
    @@logger ||= Logger.new('log/task_mgr.log')
  end
end
