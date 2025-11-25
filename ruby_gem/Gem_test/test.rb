require 'bundler/setup'
require 'my_gem'
require 'csv'

source_file = "example.xlsx"
target_file = "result.csv"

converter = MyGem::Converter.new(source_file, target_file)
converter.convert
puts "Конвертация завершена! CSV создан: #{target_file}"

CSV.foreach(target_file) do |row|
  puts row.join(", ")
end
