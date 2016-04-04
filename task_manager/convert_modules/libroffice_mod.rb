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
        system "libreoffice --convert-to #{task.output_extension} --outdir ../temp_files  ../#{task.gotten_file_path} --invisible"

        task.state = 'finished'
        task.updated_at = Time.now
        task.converted_file_path = "../#{task.gotten_file_path.sub(/#{task.input_extension}$/i,
                                                                   task.output_extension)}"
        task.finished_at = Time.now
        task.save
      rescue Exception => e
        puts e.message
      end
    end
  end
end