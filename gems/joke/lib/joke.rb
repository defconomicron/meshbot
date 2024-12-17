($COMMAND_KEYWORDS ||=[]) << '@joke'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Joke.new(args[:bot], args[:channel]).msg if /^@joke/i =~ args[:payload]}
class Joke
  # SOURCE: https://www.fatherly.com/entertainment/funniest-poop-jokes-and-poop-puns-for-kids
  require 'csv'
  JOKES = CSV.read("#{File.dirname(__FILE__)}/jokes.csv")

  def initialize(bot, channel)
    @bot = bot
    @channel = channel
  end

  def msg
    return if @bot.thread.present? && @bot.thread.alive?
    joke, answer = Joke::JOKES.sample
    @bot.send_msg(joke, @channel)
    @bot.thread = Thread.new {
      sleep 30
      bot.send_msg(answer, @channel)
    } if answer.present?
    nil
  end
end
