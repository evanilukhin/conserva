Sequel.migration do
  up do
    rename_column :convert_tasks, :gotten_file_path, :received_file_path
  end

  down do
    rename_column :convert_tasks, :received_file_path, :gotten_file_path
  end
end