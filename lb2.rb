def slice_pie(pie)
  pieces = []
  pie.each do |row|
    pieces << [row]
  end
  pieces
end


pie = [
  ".о......",
  "......о.",
  "....о...",
  "..о....."
]

result = slice_pie(pie)
result.each_with_index do |piece, i|
  puts "Шматок #{i + 1}:"
  puts piece
  puts "---"
end
