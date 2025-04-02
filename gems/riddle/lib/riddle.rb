($COMMAND_KEYWORDS ||= []) << '@riddle'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Riddle.new(args[:ch_index]).msg if /^@riddle/i =~ args[:payload]}
class Riddle
  # CREDIT: https://parade.com/947956/parade/riddles/
  require 'csv'
  RIDDLES = CSV.read("#{File.dirname(__FILE__)}/riddles.csv")

  def initialize(ch_index)
    @ch_index = ch_index
  end

  def msg
    return if $thread.present? && $thread.alive?
    riddle, answer = Riddle::RIDDLES.sample
    $message_transmitter.transmit(ch_index: @ch_index, message: riddle)
    $thread = Thread.new {
      sleep 30
      $message_transmitter.transmit(ch_index: @ch_index, message: answer)
    } if answer.present?
    nil
  end
end

