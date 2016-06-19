Sequel.migration do
  up do
    alter_table(:convert_tasks) do
      add_column :source_file_sha256, String, fixed: true, size: 64
      add_column :result_file_sha256, String, fixed: true, size: 64
    end
  end

  down do
    alter_table(:convert_tasks) do
      drop_column :source_file_sha256
      drop_column :result_file_sha256
    end
  end
end