# @todo создать базовый класс от которого модули будут наследоваться
module ImageConvert
  include BaseConvertModule

  def self.valid_combinations
    {
        from: %w(png jpg),
        to: %w(jpg png bmp)
    }
  end

  def self.run(options = {})
    # @todo вместо system попропбовать Open3
    system "convert ../#{options[:source_path]} ../#{options[:destination_path]}"

  end

end

ConvertModulesLoader::ConvertModule.register ImageConvert