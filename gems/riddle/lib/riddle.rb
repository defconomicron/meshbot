($COMMAND_KEYWORDS ||=[]) << '@riddle'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args|
  bot = args[:bot]
  if /^@riddle/i =~ args[:payload] && (bot.thread.nil? || !bot.thread.alive?)
    riddle, answer = Riddle::RIDDLES.sample
    bot.send_msg(riddle, args[:to])
    bot.thread = Thread.new {
      sleep 60
      bot.send_msg(answer, args[:to])
    }
    nil
  end
}

class Riddle
  # CREDIT: https://parade.com/947956/parade/riddles/
  require 'csv'
  RIDDLES = CSV.read("#{File.dirname(__FILE__)}/riddles.csv")

  def initialize
  end

  def msg
  end
end

