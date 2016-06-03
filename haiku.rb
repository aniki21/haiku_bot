require 'yaml'
require 'discordrb'
require 'ostruct'

# --------------------------------------------------------- #
# Config 
# --------------------------------------------------------- #

CONFIG = YAML.load_file(File.join(__dir__,"config.yml"))

# --------------------------------------------------------- #
# Methods
# --------------------------------------------------------- #

def syllable_count(w)
  word = "#{w}"
  word.downcase!
  return 1 if word.length <= 3
  word.sub!(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '')
  word.sub!(/^y/, '')
  word.scan(/[aeiouy]{1,2}/).size
end

def syllables(sentence="")
  words = sentence.gsub(/\W+/," ").split(" ")

haiku = true

  count = 0

  line_syll = 0
  line = 0
  lengths = [5,7,5]
  lines = []

  words.each do |word|
    word_syll = syllable_count(word)
    count += word_syll
    line_syll += word_syll

    lines[line] ||= []
    lines[line].push(word)
    if !lengths[line].nil? && line_syll >= lengths[line]
      haiku = false if line_syll > lengths[line]
      line = line + 1 # take a new line
      line_syll = 0 # reset the counter
    end
  end

  haiku = haiku && count == 17

  return OpenStruct.new({ syllables: count, words: words, haiku: haiku, lines: lines })
end

def haiku(sentence="")
  message = syllables(sentence)
  if message.haiku
    message.lines.each do |line|
      puts line.join(" ")
    end
  else
    # nothing
  end
end

# --------------------------------------------------------- #
# Bot
# --------------------------------------------------------- #

# Login
bot = Discordrb::Bot.new token: CONFIG["token"], application_id: CONFIG["application_id"]

# Startup
bot.ready() do |event|
  #bot.game = ""
end

bot.message() do |event|
  message = syllables(event.content)
  if message.haiku
    event.respond("```\n#{message.lines.map{|l| l.join(" ") }.join("\n")}\n```")
  end
end

# --------------------------------------------------------- #
# Run the bot and restart on errors
# --------------------------------------------------------- #
begin
  # Run the bot
  puts "---"
  puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} -- Starting "
  bot.run
rescue Exception => e
  puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} -- #{e.message}"
  retry
end
