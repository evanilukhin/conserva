require "#{ENV['root']}/modules/convert_modules/base_module"
require 'open3'

module ConvertModulesLoader
  # автоподключение всех файлов модулей
  class ConvertModule # @todo заменить на модуль
    class << self
      def init
        @modules = []
      end

      def register(name)
        @modules |= [name]
      end

      def modules
        @modules
      end
    end
  end

  ConvertModule.init
  Dir["#{ENV['root']}/modules/convert_modules/*.rb"].each {|file| require file }
end
