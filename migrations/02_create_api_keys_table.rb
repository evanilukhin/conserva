Sequel.migration do
  up do
    DB.transaction do
      create_table(:api_keys) do
        String :id, size: 36, primary_key: true
        String :comment
      end

      alter_table(:convert_tasks) do
        add_foreign_key :api_key_id, :api_keys, type: String, size: 36
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