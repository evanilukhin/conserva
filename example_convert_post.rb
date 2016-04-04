require 'rest-client'
RestClient.proxy = ''
RestClient.post 'http://localhost:9292/convert_file',
                input_extension: "txt",
                output_extension: "pdf",
                file: File.new("test_files/gui.txt", 'rb')