Sequel.migration do
  up do
    alter_table(:convert_tasks) do
      add_column :downloads_count, Integer, default: 0
      add_column :last_download_time, DateTime
    end
  end

  down do
    alter_table(:convert_tasks) do
      drop_column :last_download_time
      drop_column :downloads_count
    end
  end
end