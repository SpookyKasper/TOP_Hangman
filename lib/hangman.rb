require 'open-uri'
require 'yaml'

puts
puts "Hangman Initialized"

class Hangman

  attr_accessor :guesses_left
  attr_reader :secret_word, :coded_array

  DICTIONARY = File.open('words', 'r')
  WORDS_WITH_DESIRED_LENGTH = DICTIONARY.readlines.select {|word| word.chomp.length > 4 && word.chomp.length < 13}

  def initialize(guesses_left, secret_word, coded_array, right_letters, wrong_letters)
    @guesses_left = guesses_left
    @secret_word = secret_word
    @coded_array = coded_array
    @right_letters = right_letters
    @wrong_letters = wrong_letters
  end

  def letter_guess_loop
    while 1
      puts "Please type a letter"
      letter = gets.chomp.downcase
      next unless ('a'..'z').to_a.include?(letter)
      return letter unless @right_letters.include?(letter) || @wrong_letters.include?(letter)
      puts "You already guessed that letter hehe, check the secret word and the wrong letters before guessing ;)"
    end
  end

  def deal_with_user_input
    letter = letter_guess_loop
    if @secret_word.include?(letter)
      @right_letters << letter && right_letter_message
    else
      @wrong_letters << letter && wrong_letter_message
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

  def victory?
    @coded_array.join.gsub(/\W+/, '') == @secret_word
  end

  def guess
    deal_with_user_input
    update_coded_array
  end

  def save
    Dir.mkdir("saved_games") unless File.exists?("saved_games")
    puts 'Under which name should we store your game ?'
    name = gets.chomp
    File.open("saved_games/#{name}.yml", 'w') {|f| f.write(to_yaml)}
    puts "Your game has just been saved under #{name}"
  end

  def guess_or_save
    choice = nil
    puts "Do you want to make a guess or save the game ?"
    puts "Please type 'g' to guess and 's' to save"
    until choice == 'g' || choice == 's'
      choice = gets.chomp
      next if choice == 'g' || choice == 's'
      puts "Something seems wrong with your input, Please type 'g' or 's'"
    end
    choice == 'g' ? guess : save
  end

  def game_loop
    until guesses_left == 0 || victory?
      display
      guess_or_save
    end
  end

  # Player Display and messages

  def display
    puts
    puts "The secret word is"
    puts @coded_array.join
    puts
    puts "The letters you guessed that are NOT in the secret word are:#{@wrong_letters}"
    puts "You can still make #{@guesses_left} incorrect guesses before the game ends"
    puts
  end

  def right_letter_message
    puts
    puts "Nice! That letter is present in the secred word!"
  end

  def wrong_letter_message
    puts
    puts "Ooh too bad that letter is not present in the secret code :("
  end

  def not_a_letter_message
    puts
    puts "Oh it looks like you didn't typed a letter.. please type a letter"
  end

  def victory_message
    puts
    puts "Congratulations you cracked the secret word before being Hanged!"
    puts
    puts "'#{@coded_array.join.delete(' ')}' was the secret word indeed!"
    puts
  end

  def defeat_message
    puts "Too bad you just got hanged before cracking the secret word :("
    puts
    puts "This was your result so far #{@coded_array.join}"
    puts
  end

  def end_game_message
    victory? ? victory_message : defeat_message
  end

  # Serialize / Deserialize Methods

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
    self.new(data[:guesses_left], data[:secret_word], data[:coded_array], data[:right_letters], data[:wrong_letters])
  end

  # CLASS METHODS
  def self.create_new_game
    secret_word = WORDS_WITH_DESIRED_LENGTH.sample.chomp
    coded_array = secret_word.split('').map { |letter| '_ ' }
    self.new(12, secret_word, coded_array, Array.new(), Array.new())
  end

  def self.load_game
    puts "Which game you want to load?"
    puts "Here are your saved games:"
    puts Dir.chdir('saved_games') {Dir.glob('*')}
    name = gets.chomp
    stored = File.open("saved_games/#{name}")
    Hangman.from_yaml(stored)
  end

  def self.load_or_new?
    puts
    puts "Do you want to start from scratch or load a saved game?"
    puts
    puts "Please type 'new' if you want to start from scratch"
    puts "Please type 'old' if you want to load a saved game"
    gets.chomp
  end

  def self.start_fresh_or_load(choice)
    if choice == 'new'
      self.create_new_game
    elsif choice == 'old'
      self.load_game
    else
      puts "that doesn't seem right"
    end
  end

  def self.play
    if Dir.exists?('saved_games')
      choice = self.load_or_new?
      game = self.start_fresh_or_load(choice)
    else
      game = self.start_fresh_or_load('new')
    end
    game.game_loop
    game.end_game_message
  end
end


while 1
  Hangman.play
  puts "Do you want to play again ?"
  answer = gets.chomp
  until answer == 'yes' || answer == 'no'
    puts "Please type 'yes' or 'no' depending on your choice"
    answer = gets.chomp
  end
  next if answer == 'yes'
  return if answer == 'no'
end
