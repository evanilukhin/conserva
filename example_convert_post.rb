require 'rest-client'
RestClient.proxy = ''
RestClient.post 'http://localhost:9292/convert_file',
                input_extension: "jpg",
                output_extension: "png",
                file: File.new("test_files/test_5.jpg", 'rb')