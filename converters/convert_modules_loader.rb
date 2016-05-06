require "#{ENV['root']}/converters/base_module"
require 'open3'

module ConvertModulesLoader
  # автоподключение всех файлов модулей
  class ConvertModule # @todo заменить на модуль
    class << self
      def init
        @converters = []
      end

      def register(name)
        @converters |= [name]
      end

      def modules
        @converters
      end
    end
  end

  ConvertModule.init
  Dir["#{ENV['root']}/converters/*.rb"].each {|file| require file }
end
