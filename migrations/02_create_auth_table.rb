Sequel.migration do
  up do
    DB.transaction do
      create_table(:auth_tokens) do
        primary_key :id
        String :uuid, size: 36
        String :comment
      end

      alter_table(:convert_tasks) do
        add_foreign_key :auth_token_id, :auth_tokens
      end
    end
  end

  down do
    alter_table(:convert_tasks) do
      drop_foreign_key :auth_token_id
    end
    drop_table(:auth_tokens)
  end
end