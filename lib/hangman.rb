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

  attr_accessor :guesses_left
  attr_reader :secret_word

  def initialize(guesses)
    @guesses_left = guesses
    @secret_word = WANTED_LENGTH_WORDS.sample.chomp
    @coded_array = []
    @right_letters = []
    @wrong_letters = []
    @current_letter = nil
  end

  def display
    puts "You can still make #{@guesses_left} incorrect guesses before the game ends"
    puts "The letters you guessed that are NOT in the secret word are: #{@wrong_letters}"
    puts "The secret word is"
    puts  @coded_array.join
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
      @guesses_left -= 1
    end
  end

  def update_coded_array
    @secret_word.split('').each_with_index do |letter, index|
      if @right_letters.include?(letter)
        @coded_array[index] = "#{letter} "
      end
    end
  end

  def victory
    @coded_array.join.gsub(/\W+/, '') == @secret_word
  end

  def victory_message
    puts "Congratulations you cracked the secret word before being Hanged!"
  end

  def defeat_message
    puts "Too bad you just got hanged before cracking the secret word :("
  end
end


game = Hangman.new(2)
game.code_secret_word

until game.guesses_left == 0 || game.victory
  p game.secret_word
  game.display
  game.get_user_input
  game.deal_with_input_letters
  game.update_coded_array
end

game.display
game.victory ? game.victory_message : game.defeat_message
