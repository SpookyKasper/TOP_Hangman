require 'open-uri'

puts "Hangman Initialized"

# Algo Hangman:
# Make an array of the alphabet
# display the empty slots of the word ex: 'five' = _ _ _ _ _
# display a counter of the guesses left
# Ask the user to pick a letter
# Update the display if the letter is present in the secret word
# Update the counter if not


class Hangman

  DICTIONARY = File.open('words', 'r')
  WANTED_LENGTH_WORDS = DICTIONARY.readlines.select {|word| word.chomp.length > 4 && word.chomp.length < 13}

  def initialize(guesses)
    @guesses = guesses
    @secret_word = WANTED_LENGTH_WORDS.sample.chomp
    @right_letter = []

  end

  def display_guesses_left
    puts "You can still make #{@guesses} incorrect guesses before the game ends"
  end

  def display_coded_word
    coded_array = @secret_word.split('').map do |letter|
      '_ '
    end
    p coded_array.join
  end
end


game = Hangman.new(3)

game.display_coded_word

