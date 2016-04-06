require 'rest-client'
RestClient.proxy = ''
RestClient.post 'http://localhost:9292/convert_file',
                input_extension: "png",
                output_extension: "jpg",
                file: File.new("test_files/test_3.png", 'rb')