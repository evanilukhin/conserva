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

      def valid_combinations
        @converters.inject([]) do |combinations, converter|
          combinations |= [converter.valid_combinations[:from],
                           converter.valid_combinations[:to]].comprehension.to_a
        end
      end
    end
  end

  ConvertModule.init
  Dir["#{ENV['root']}/converters/*.rb"].each {|file| require file }

end
