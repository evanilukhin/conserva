module ConvertModulesLoader
  # автоподключение всех файлов модулей
  class ConvertModule
    class << self
      def init
        @modules = []
      end
      def register module_class_name
        @modules |= [module_class_name]
      end

      def modules
        @modules
      end
    end
  end

  ConvertModule.init
  Dir["#{Dir.pwd}/convert_modules/*.rb"].each {|file| require_relative file }
end
