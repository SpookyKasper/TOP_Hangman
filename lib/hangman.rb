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
    puts "The secret word is"
    puts  @coded_array.join
    puts "The letters you guessed that are NOT in the secret word are: #{@wrong_letters}"
    puts "You can still make #{@guesses_left} incorrect guesses before the game ends"
    puts
  end

  def deal_with_user_input
    puts "Please type a letter"
    current_letter = gets.chomp.downcase
    @secret_word.include?(current_letter) ?
    @right_letters << current_letter && right_letter_message :
    @wrong_letters << current_letter && wrong_letter_message && @guesses_left -=1
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

  def right_letter_message
    puts "Nice! That letter is present in the secred word!"
  end

  def wrong_letter_message
    puts "Ooh too bad that letter is not present secret code :("
  end

  def victory_message
    puts "Congratulations you cracked the secret word before being Hanged!"
  end

  def defeat_message
    puts "Too bad you just got hanged before cracking the secret word :("
  end

  def end_of_game_message
    puts
    victory ? victory_message : defeat_message
    puts @coded_array.join
  end

  def guess
    p @secret_word
    deal_with_user_input
    update_coded_array
  end

  def save
    now = Time.new
    File.open("saved_games/#{now}", 'w') {|f| f.write(to_yaml)}
    puts "Your game has just been saved!"
  end

  def guess_or_save(choice)
    choice == 'guess' ? guess : save
  end

  def to_yaml
    YAML.dump ({
      :guesses_left => @guesses_left,
      :secret_word => @secret_word,
      :coded_array => @coded_array,
      :right_letters => @right_letters,
      :wrong_letters => @wrong_letters,
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

game = Hangman.new(3, secret_word, coded_array, Array.new(), Array.new())

Dir.mkdir("saved_games") unless File.exists?("saved_games")


until game.guesses_left == 0 || game.victory
  game.display
  puts "Do you want to make a guess or save the game ?"
  choice = gets.chomp
  game.guess_or_save(choice)
end

game.end_of_game_message
