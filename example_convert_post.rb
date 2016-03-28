require 'rest-client'
RestClient.proxy = ''
RestClient.post 'http://localhost:9292/convert_file',
                input_extension: "rb",
                output_extension: "pdf",
                file: File.new("example_convert_post.rb", 'rb')