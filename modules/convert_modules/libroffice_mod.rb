module LibreOfficeConvert
  self.extend BaseConvertModule

  class<<self
    def valid_combinations
      {
          from: %w(doc txt odt),
          to: %w(pdf)
      }
    end

    def run(options = {})
      run_command("timeout #{timeout_time} libreoffice --convert-to #{options[:output_extension]} --outdir #{options[:output_dir]}  #{options[:source_path]} --invisible")
    end

    def timeout_time
      300
    end

    def result_handler output, state
      if state.exitstatus == 0
        false
      else
        true
      end
    end
  end
end

ConvertModulesLoader::ConvertModule.register LibreOfficeConvert