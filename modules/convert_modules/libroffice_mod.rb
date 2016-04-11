module LibreOfficeConvert
  include BaseConvertModule
  def self.valid_combinations
    {
        from: %w(doc txt odt),
        to: %w(pdf)
    }
  end

  def self.run(options = {})

    system "libreoffice --convert-to #{options[:output_extension]} --outdir ../#{options[:output_dir]}  ../#{options[:source_path]} --invisible"
  end
end

ConvertModulesLoader::ConvertModule.register LibreOfficeConvert