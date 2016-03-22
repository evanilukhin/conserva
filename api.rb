require 'sinatra'

get '/state_convertation' do
  'State return'
end

post '/upload' do
  if params[:file]
    filename = params[:file][:filename]
    tempfile = params[:file][:tempfile]
    target = "public/files/#{filename}"

    File.open(target, 'wb') { |f| f.write tempfile.read }
  end
end
