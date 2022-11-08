require 'open-uri'

puts "Hangman Initialized"

# Algo Hangman:
# Make an array of the alphabet
# display the empty slots of the word ex: 'five' = _ _ _ _ _
# display a counter of the guesses left
# Ask the user to pick a letter
# Check if that letter is present in the secret code
# If it is then modify the display to show where that letter appears


class Hangman

  DICTIONARY = File.open('words', 'r')
  WANTED_LENGTH_WORDS = DICTIONARY.readlines.select {|word| word.chomp.length > 4 && word.chomp.length < 13}

  attr_accessor :secret_word

  def initialize(guesses)
    @guesses = guesses
    @secret_word = WANTED_LENGTH_WORDS.sample.chomp
    @coded_array = []
    @right_letters = []
    @wrong_letters = []
    @current_letter = nil
  end

  def display_guesses_left
    puts "You can still make #{@guesses} incorrect guesses before the game ends"
  end

  def display_coded_word
    puts "The secret word is #{@coded_array.join}"
  end

  def code_secret_word
    @coded_array = @secret_word.split('').map {|letter| '_ '}
  end

  def get_user_input
    puts "Please type a letter"
    @current_letter = gets.chomp.downcase
  end

  def deal_with_input_letters
    if @secret_word.include?(@current_letter)
      @right_letters << @current_letter
    else
      @wrong_letters << @current_letter
    end
  end

  def update_coded_array
    @secret_word.split('').each_with_index do |letter, index|
      if @right_letters.include?(letter)
        @coded_array[index] = "#{letter} "
      end
    end
  end
end


game = Hangman.new(3)

p game.secret_word
game.code_secret_word
game.display_coded_word
game.display_guesses_left

game.get_user_input
game.deal_with_input_letters
game.update_coded_array
game.display_guesses_left
game.display_coded_word

