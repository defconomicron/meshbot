($COMMAND_KEYWORDS ||= []) << '@joke'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Joke.new(args[:ch_index]).msg if /^@joke/i =~ args[:payload]}
class Joke
  # SOURCE: https://www.fatherly.com/entertainment/funniest-poop-jokes-and-poop-puns-for-kids
  require 'csv'
  JOKES = CSV.read("#{File.dirname(__FILE__)}/jokes.csv")

  def initialize(ch_index)
    @ch_index = ch_index
  end

  def msg
    return if $tx_bot.thread.present? && $tx_bot.thread.alive?
    joke, answer = Joke::JOKES.sample
    $tx_bot.send_text(joke, @ch_index)
    $tx_bot.thread = Thread.new {
      sleep 30
      $tx_bot.send_text(answer, @ch_index)
    } if answer.present?
    nil
  end
end
