class  LibreOfficeConvert
  class << self
    def valid_combinations
      {
          from: %w(doc txt),
          to:   %w(pdf)
      }
    end
    def run task
      begin
        system "libreoffice --convert-to #{task.output_extension} --outdir ../temp_files  /#{task.gotten_file_path}"
      rescue Exception =>e
        puts e.message
      end
    end
  end
end