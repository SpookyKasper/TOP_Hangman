require 'open-uri'
require 'yaml'

puts "Hangman Initialized"

# Algo Hangman:
# Make an array of the alphabet
# display the empty slots of the word ex: 'five' = _ _ _ _ _
# display a counter of the guesses left
# Ask the user to pick a letter
# Check if that letter is present in the secret code
# If it is then modify the display to show where that letter appears

class Hangman

  attr_accessor :guesses_left
  attr_reader :secret_word, :coded_array

  def initialize(guesses_left, secret_word, coded_array, right_letters, wrong_letters)
    @guesses_left = guesses_left
    @secret_word = secret_word
    @coded_array = coded_array
    @right_letters = []
    @wrong_letters = []
    @current_letter = nil
  end

  def display
    puts
    puts "You can still make #{@guesses_left} incorrect guesses before the game ends"
    puts "The letters you guessed that are NOT in the secret word are: #{@wrong_letters}"
    puts "The secret word is"
    puts  @coded_array.join
    puts
  end

  def deal_with_user_input
    puts "Please type a letter"
    current_letter = gets.chomp.downcase
    @secret_word.include?(current_letter) ? @right_letters << current_letter : @wrong_letters << current_letter and @guesses_left -=1
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

  def guess
    until guesses_left == 0 || victory
      p @secret_word
      display
      deal_with_user_input
      update_coded_array
    end
  end

  def to_yaml
    YAML.dump ({
      :guesses_left => @guesses_left,
      :secret_word => @secret_word,
      :coded_array => @coded_array,
      :right_letters => @right_letters,
      :wrong_letters => @wrong_letters,
      :current_letter => @current_letter
    })
  end

  def self.from_yaml(string)
    data = YAML.load string
    p data
    self.new(data[:guesses_left], data[:secret_word], data[:coded_array], data[:right_letters], data[:wrong_letters], data[:current_letter])
  end
end

dictionary = File.open('words', 'r')
words_with_wanted_length = dictionary.readlines.select {|word| word.chomp.length > 4 && word.chomp.length < 13}
secret_word = words_with_wanted_length.sample.chomp
coded_array = secret_word.split('').map { |letter| '_ ' }

game = Hangman.new(2, secret_word, coded_array, Array.new(), Array.new())

puts "Do you want to make a guess or save the game ?"
choice = gets.chomp
choice == 'guess' ? game.guess : game.to_yaml


puts
game.victory ? game.victory_message : game.defeat_message
p game.coded_array.join
