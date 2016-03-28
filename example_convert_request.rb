require 'net/http'
require 'uri'


url = "http://localhost:9292/convert_file"
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.request_uri)

parameters = { input_extension: 'zip',
               output_extension: 'pdf',
               filename: 'z.zip',
               tempfile: File.read('195_98766.zip') }

request.set_form_data(parameters)
http.request(request)