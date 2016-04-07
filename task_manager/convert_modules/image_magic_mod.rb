# @todo создать базовый класс от которого модули будут наследоваться
class ImageConvert
  class << self

    def valid_combinations
      {
          from: %w(png jpg),
          to:   %w(jpg png)
      }
    end

    def run task # @todo вместо задачи фиксированное количество параметров

        # @todo вместо system попропбовать Open3
        system "convert ../#{task.gotten_file_path} ../#{task.gotten_file_path.sub(/#{task.input_extension}$/i,
                                                                                   task.output_extension)}"


        # @todo вынести в TaskManager
        task.state = ConvertState.finished
        task.updated_at = Time.now
        task.converted_file_path = "#{task.gotten_file_path.sub(/#{task.input_extension}$/i,
                                                                   task.output_extension)}"
        task.finished_at = Time.now
        task.save
    end
  end
end

ConvertModulesLoader::ConvertModule.register ImageConvert