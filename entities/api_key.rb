class ApiKey < Sequel::Model(:api_keys)
  one_to_many :convert_tasks
end