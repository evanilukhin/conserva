require 'rest-client'
def convert_file(filename, result_extension)
  input_extension = File.extname(filename)[1..-1]
  begin
  response = RestClient.post 'http://localhost:9292/convert_file',
                  input_extension: input_extension,
                  output_extension: result_extension,
                  file: File.new(filename, 'rb')
  puts response.code
  puts response.cookies
  puts response.headers
  puts response.to_str
  rescue => e
    puts e.response.code
    puts e.response.cookies
    puts e.response.headers
    puts e.response.to_str
  end


end
RestClient.proxy = ''
3.times do
  #convert_file('test_files/test_1.odt','pdf')
  #convert_file('test_files/test_2.doc','pdf')
  #convert_file('test_files/test_3.txt','pdf')
  convert_file('test_files/test_4.jpg','bmp')
  sleep 1
end
