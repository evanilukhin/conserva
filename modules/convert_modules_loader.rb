require_relative 'convert_modules/base_module'
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
  Dir["#{Dir.pwd}/convert_modules/*.rb"].each {|file| require_relative file }
end
