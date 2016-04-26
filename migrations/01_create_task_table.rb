# file_input: File - полученный файл
# file_output : File - сконвертированный файл
# input_extension: String  - тип полученного файла
# output_extension: String - в какое расширение конвртировать
# created_at: Time - время добавления
# finished_at: Time - время завершения
# state: String  - состояние
# errors: Text - ошибки

Sequel.migration do
  up do
    create_table(:convert_tasks) do
      primary_key :id
      String :source_file
      String :converted_file
      String :input_extension
      String :output_extension
      String :state
      DateTime :created_at
      DateTime :updated_at
      DateTime :finished_at
      String :errors, text: true
    end
  end

  down do
    drop_table(:convert_tasks)
  end
end
