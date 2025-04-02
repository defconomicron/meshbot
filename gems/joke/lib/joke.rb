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
    return if $thread.present? && $thread.alive?
    joke, answer = Joke::JOKES.sample
    $message_transmitter.transmit(ch_index: @ch_index, message: joke)
    $thread = Thread.new {
      sleep 30
      $message_transmitter.transmit(ch_index: @ch_index, message: answer)
    } if answer.present?
    nil
  end
end
