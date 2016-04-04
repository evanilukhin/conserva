require 'rest-client'
RestClient.proxy = ''
RestClient.post 'http://localhost:9292/convert_file',
                input_extension: "dwg",
                output_extension: "pdf",
                file: File.new("test_files/test_4.dwg", 'rb')