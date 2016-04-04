class QcadConvert
  class << self

    def valid_combinations
      {
          from: %w(dwg),
          to:   %w(pdf bmp)
      }
    end

    def run task
      begin
        case task.output_extension
          when 'pdf'
            system "~/opt/qcad-3.13.1-linux-x86_64/dwg2pdf ../#{task.gotten_file_path}"
          when 'bmp'

          else
            # type code here
        end

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