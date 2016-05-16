class AuthToken < Sequel::Model(:auth_tokens)
  one_to_many :convert_tasks
end