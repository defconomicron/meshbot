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
    return if $tx_bot.thread.present? && $tx_bot.thread.alive?
    riddle, answer = Riddle::RIDDLES.sample
    $tx_bot.send_text(riddle, @ch_index)
    $tx_bot.thread = Thread.new {sleep 30;$tx_bot.send_text(answer, @ch_index)} if answer.present?
    nil
  end
end

