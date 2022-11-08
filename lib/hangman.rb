require 'open-uri'

puts "Hangman Initialized"

remote_url = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt'

remote_data = URI.open(remote_url).read

local_file = File.open('words', 'w')

local_file.write(remote_data)




