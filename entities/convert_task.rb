class ConvertTask < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:state, :input_extension, :output_extension]
    case state
      when ConvertState::RECEIVED
        validates_presence [:source_file]
        errors.add(:source_file, I18n.t(:file_not_exist, scope:'errors')) unless File.exist?("#{ENV['file_storage']}/#{source_file}")
      when ConvertState::FINISHED
        validates_presence [:source_file, :converted_file]
        errors.add(:source_file, I18n.t(:file_not_exist, scope:'errors')) unless File.exist?("#{ENV['file_storage']}/#{source_file}")
        errors.add(:converted_file, I18n.t(:file_not_exist, scope:'errors')) unless File.exist?("#{ENV['file_storage']}/#{converted_file}")
    end
  end
end