class ImageConverter < BaseConverter
  class<<self
    # jpg в pdf конвертирует плохо, лучше пока не использовать
    def valid_combinations
      {
          from: %w(png jpg bmp gif),
          to: %w(jpg png bmp pdf)
      }
    end

    def run(options = {})
      run_command("timeout #{timeout_time} convert #{options[:source_path]} #{options[:destination_path]}")
    end

    def max_launched_modules
     10
    end
  end
end

ConvertModulesLoader::ConvertModule.register ImageConverter