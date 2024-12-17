($COMMAND_KEYWORDS ||=[]) << '@joke'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args|
  bot = args[:bot]
  if /^@joke/i =~ args[:payload] && (bot.thread.nil? || !bot.thread.alive?)
    joke, answer = Joke::JOKES.sample
    bot.send_msg(joke, args[:channel])
    bot.thread = Thread.new {
      sleep 30
      bot.send_msg(answer, args[:channel])
    } if answer.present?
    nil
  end
}
class Joke
  # SOURCE: https://www.fatherly.com/entertainment/funniest-poop-jokes-and-poop-puns-for-kids
  require 'csv'
  JOKES = CSV.read("#{File.dirname(__FILE__)}/jokes.csv")

  def initialize
  end

  def msg
  end
end
