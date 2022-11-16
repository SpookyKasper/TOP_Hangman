require 'open-uri'
require 'yaml'
require 'colorize'

puts
puts 'Hangman Initialized'.light_white

class Hangman
  attr_accessor :guesses_left
  attr_reader :secret_word, :coded_array

  DICTIONARY = File.open('words', 'r')
  WORDS_WITH_DESIRED_LENGTH = DICTIONARY.readlines.select { |word| word.chomp.length > 4 && word.chomp.length < 13 }

  def initialize(guesses_left, secret_word, coded_array, right_letters, wrong_letters)
    @guesses_left = guesses_left
    @secret_word = secret_word
    @coded_array = coded_array
    @right_letters = right_letters
    @wrong_letters = wrong_letters
  end

  def letter_guess_loop
    while 1
      puts 'Please type a letter'.light_yellow
      letter = gets.chomp.downcase
      next unless ('a'..'z').to_a.include?(letter)
      return letter unless @right_letters.include?(letter) || @wrong_letters.include?(letter)

      puts 'You already guessed that letter!'.red
      puts 'check the secret word and the wrong letters before guessing ;)'.red
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
      @coded_array[index] = "#{letter} " if @right_letters.include?(letter)
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
    Dir.mkdir('saved_games') unless File.exist?('saved_games')
    puts 'Under which name should we store your game ?'
    name = gets.chomp
    File.open("saved_games/#{name}.yml", 'w') { |f| f.write(to_yaml) }
    puts "Your game has just been saved under #{name}".light_yellow
  end

  def guess_or_save
    choice = nil
    puts 'Do you want to make a guess or save the game ?'.light_cyan
    puts "Please type 'g' to guess and 's' to save".light_yellow
    until %w[g s].include?(choice)
      choice = gets.chomp
      next if %w[g s].include?(choice)

      puts "Something seems wrong with your input, Please type 'g' or 's'".red
    end
    choice == 'g' ? guess : save
  end

  def game_loop
    until guesses_left.zero? || victory?
      display
      guess_or_save
    end
  end

  # Player Display and messages

  def display
    puts
    puts 'The secret word is'.light_white
    puts @coded_array.join.light_white
    puts
    unless @wrong_letters.empty?
      puts 'The letters you guessed that are NOT in the secret word are:' + "#{@wrong_letters}".light_magenta
    end
    puts 'You can still make ' + "#{@guesses_left}".red + ' incorrect guesses before the game ends'
  end

  def right_letter_message
    puts
    puts 'Nice! That letter is present in the secred word!'.green
  end

  def wrong_letter_message
    puts
    puts 'Unfortunately that letter is not present in the secret code :('.magenta
  end

  def victory_message
    puts
    puts 'Congratulations you cracked the secret word before being Hanged!'.green
    puts
    puts "'#{@coded_array.join.delete(' ')}' was the secret word indeed!".green
    puts
  end

  def defeat_message
    puts 'Too bad you just got hanged before cracking the secret word :('.magenta
    puts
    puts "This was your result so far #{@coded_array.join}".magenta
    puts
  end

  def end_game_message
    victory? ? victory_message : defeat_message
  end

  # Serialize / Deserialize Methods

  def to_yaml
    YAML.dump({
                guesses_left: @guesses_left,
                secret_word: @secret_word,
                coded_array: @coded_array,
                right_letters: @right_letters,
                wrong_letters: @wrong_letters
              })
  end

  def self.from_yaml(string)
    data = YAML.load string
    new(data[:guesses_left], data[:secret_word], data[:coded_array], data[:right_letters], data[:wrong_letters])
  end

  # CLASS METHODS
  def self.create_new_game
    puts
    puts "Let's start a new game then!".light_white
    secret_word = WORDS_WITH_DESIRED_LENGTH.sample.chomp
    coded_array = secret_word.split('').map { |_letter| '_ ' }
    new(12, secret_word, coded_array, [], [])
  end

  def self.load_game
    puts
    puts 'Here are your saved games:'.light_yellow
    puts Dir.chdir('saved_games') { Dir.glob('*') }
    puts
    puts 'Which game you want to load?'.light_cyan
    name = gets.chomp
    until File.exist?("saved_games/#{name}")
      puts 'Please type an existing saved game'.light_yellow
      name = gets.chomp
    end
    stored = File.open("saved_games/#{name}")
    Hangman.from_yaml(stored)
  end

  def self.load_or_new?
    puts
    puts 'Do you want to start from scratch or load a saved game?'.light_cyan
    puts "Please type 'new' or 'old' depending on your choice".light_yellow
    answer = gets.chomp
    until %w[new old].include?(answer)
      puts "Please type 'new' or 'old' (withouth the quotes)".light_magenta
      answer = gets.chomp
    end
    answer
  end

  def self.start_fresh_or_load(choice)
    choice == 'new' ? create_new_game : load_game
  end

  def self.play
    if Dir.exist?('saved_games')
      choice = load_or_new?
      game = start_fresh_or_load(choice)
    else
      game = start_fresh_or_load('new')
    end
    game.game_loop
    game.end_game_message
  end
end

while 1
  Hangman.play
  puts 'Do you want to play again ?'
  answer = gets.chomp
  until %w[yes no].include?(answer)
    puts "Please type 'yes' or 'no' depending on your choice".light_yellow
    answer = gets.chomp
  end
  next if answer == 'yes'
  return if answer == 'no'
end
