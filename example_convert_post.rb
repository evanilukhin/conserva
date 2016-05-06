require 'rest-client'
def convert_file(filename, result_extension)
  input_extension = File.extname(filename)[1..-1]
  begin
  response = RestClient.post 'http://localhost:9292/convert_file',
                  input_extension: input_extension,
                  output_extension: result_extension,
                  file: File.new(filename, 'rb')
  puts [response.code,
        response.cookies,
        response.headers,
        response.to_str].join("\n")
  rescue => e
    puts [e.response.code,
          e.response.cookies,
          e.response.headers,
          e.response.to_str].join("\n")
  end


end
RestClient.proxy = ''
3.times do
  convert_file('test_files/test_1.odt','pdf')
  convert_file('test_files/test_2.doc','pdf')
  convert_file('test_files/test_3.txt','pdf')
  convert_file('test_files/test_4.jpg','bmp')
  sleep 1
end
