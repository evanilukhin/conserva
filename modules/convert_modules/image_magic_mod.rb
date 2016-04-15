# @todo создать базовый класс от которого модули будут наследоваться
module ImageConvert
  self.extend BaseConvertModule

  class<<self
    def valid_combinations
      {
          from: %w(png jpg),
          to: %w(jpg png bmp)
      }
    end

    def run(options = {})
      run_command("timeout #{timeout_time} convert #{options[:source_path]} #{options[:destination_path]}")
    end

    def max_launched_modules
     7
    end
  end

end

ConvertModulesLoader::ConvertModule.register ImageConvert