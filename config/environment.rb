environment = ENV['SINATRA_ENV'] || 'development'
Figaro.application =
    Figaro::Application.new(environment: environment, path: "config/environment.yml")
Figaro.load

Figaro.application =
    Figaro::Application.new(environment: environment, path: "config/database.yml")
Figaro.load
