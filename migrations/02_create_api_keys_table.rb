Sequel.migration do
  up do
    DB.transaction do
      create_table(:api_keys) do
        primary_key :id
        String :uuid, size: 36, unique: true
        String :name
        String :comment
      end

      alter_table(:convert_tasks) do
        add_foreign_key :api_key_id, :api_keys
      end
    end
  end

  down do
    DB.transaction do
      alter_table(:convert_tasks) do
        drop_foreign_key :api_key_id
      end
      drop_table(:api_keys)
    end
  end
end