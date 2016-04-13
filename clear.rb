require 'sequel'
Dir["#{Dir.pwd}/temp_files/*.pdf"].each {|file| File.delete file }
Dir["#{Dir.pwd}/temp_files/*.bmp"].each {|file| File.delete file }
DB = Sequel.connect('sqlite://conserv.db')
DB[:convert_tasks].update(state: 'rec')