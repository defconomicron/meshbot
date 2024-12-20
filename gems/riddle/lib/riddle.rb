($COMMAND_KEYWORDS ||=[]) << '@riddle'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Riddle.new(args[:channel]).msg if /^@riddle/i =~ args[:payload]}
class Riddle
  # CREDIT: https://parade.com/947956/parade/riddles/
  require 'csv'
  RIDDLES = CSV.read("#{File.dirname(__FILE__)}/riddles.csv")

  def initialize(channel)
    @channel = channel
  end

  def msg
    return if $tx_bot.thread.present? && $tx_bot.thread.alive?
    riddle, answer = Riddle::RIDDLES.sample
    $tx_bot.send_text(riddle, @channel)
    $tx_bot.thread = Thread.new {
      sleep 30
      $tx_bot.send_text(answer, @channel)
    } if answer.present?
    nil
  end
end

