# def word_stats(text1)
#     count_unique = text1.split.map(&:downcase).uniq.length
#     counts = text1.split.count
#     max_length = text1.split.max_by { |t|  t.length }
#     puts "text = #{text1}\n# -> #{counts}, найдовше слово: #{max_length}, унікальних: #{count_unique}"
# end

# puts "Введіть текст:"
# text = gets.chomp
# word_stats(text)

# --------------------------
# def play_game
#     random_number = rand(10)
#      counts = 1
    
# while true
#   print "Введи число: "
#   number = gets.to_i
#     if number == random_number
#             puts "Молодець! спроб: #{counts}"
#             return

#     elsif number > random_number
#       puts "number > random_number"
#     else
#       puts "number < random_number"
#     end
#     counts += 1
# end
# end

# play_game