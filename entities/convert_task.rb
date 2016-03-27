class ConvertTask < Sequel::Model
  def to_s
    self.to_hash
  end
end