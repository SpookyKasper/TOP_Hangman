require 'open-uri'

puts "Hangman Initialized"

dictionary = File.open('words', 'r')

words_array = dictionary.readlines

wanted_length_words = words_array.select {|word| word.chomp.length > 4 && word.chomp.length < 13}

wanted_length_words.each do |word|
  puts word.chomp.length
end

secret_word = wanted_length_words.sample.chomp

p secret_word


