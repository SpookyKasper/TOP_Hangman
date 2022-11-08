require 'open-uri'

puts "Hangman Initialized"

dictionary = File.open('words', 'r')

random_word = dictionary.readlines.sample.chomp

p random_word

