require 'rest-client'
RestClient.proxy = ''
RestClient.post 'http://localhost:9292/convert_file',
                input_extension: "png",
                output_extension: "pdf",
                file: File.new("temp_files/3.png", 'rb')