require "rubygems"
require "sequel"

DB = Sequel.connect('postgres://xenomorf:ananas@localhost:5432/')
items = DB[:items]
puts "Item count: #{items.count}"
puts "The average price is: #{items.avg(:price)}"
