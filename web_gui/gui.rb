require "sinatra"
require 'haml'

set :port, 5678

get '/' do
  haml :web_gui
end
