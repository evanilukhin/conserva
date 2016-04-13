class ConvertTask < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:state, :input_extension, :output_extension]
    errors.add(:received_file_path, "Received file must exist") unless File.exist?(received_file_path)
    case state
      when ConvertState::RECEIVED
        validates_presence [:received_file_path]
        errors.add(:received_file_path, "Received file must exist") unless File.exist?(received_file_path)
      when ConvertState::FINISHED
        validates_presence [:received_file_path, :converted_file_path]
        errors.add(:received_file_path, "Received file must exist") unless File.exist?(received_file_path)
        errors.add(:converted_file_path, "Received file must exist") unless File.exist?(converted_file_path)
    end
  end
end