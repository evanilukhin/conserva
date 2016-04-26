class ConvertTask < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:state, :input_extension, :output_extension]
    case state
      when ConvertState::RECEIVED
        validates_presence [:received_file_path]
        errors.add(:received_file_path, I18n.t(:file_not_exist, scope:'errors')) unless File.exist?("#{ENV['file_storage']}/#{received_file_path}")
      when ConvertState::FINISHED
        validates_presence [:received_file_path, :converted_file_path]
        errors.add(:received_file_path, I18n.t(:file_not_exist, scope:'errors')) unless File.exist?("#{ENV['file_storage']}/#{received_file_path}")
        errors.add(:converted_file_path, I18n.t(:file_not_exist, scope:'errors')) unless File.exist?("#{ENV['file_storage']}/#{converted_file_path}")
    end
  end
end