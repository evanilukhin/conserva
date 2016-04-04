module ConvertModules
  # автоподключение всех файлов модулей
  Dir["#{Dir.pwd}/convert_modules/*.rb"].each {|file| require_relative file }
  # перечисление классов конверторов, содержащихся в вышеподключённых модулях
  @modules = [LibreOfficeConvert, QcadConvert] # @todo а не запихнуть ли всё в хэш вместе с доступными комбинациями

  def self.modules
    return @modules
  end
end
