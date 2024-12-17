($COMMAND_KEYWORDS ||=[]) << '@riddle'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Riddle.new(args[:bot], args[:channel]).msg if /^@riddle/i =~ args[:payload]}
class Riddle
  # CREDIT: https://parade.com/947956/parade/riddles/
  require 'csv'
  RIDDLES = CSV.read("#{File.dirname(__FILE__)}/riddles.csv")

  def initialize(bot, channel)
    @bot = bot
    @channel = channel
  end

  def msg
    return if @bot.thread.present? && @bot.thread.alive?
    riddle, answer = Riddle::RIDDLES.sample
    @bot.send_text(riddle, @channel)
    @bot.thread = Thread.new {
      sleep 30
      @bot.send_text(answer, @channel)
    } if answer.present?
    nil
  end
end

