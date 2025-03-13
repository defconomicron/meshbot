($COMMAND_KEYWORDS ||= []) << '@time'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Clock.new.msg if /^@time/i =~ args[:payload]}
class Clock
  def initialize
  end

  def msg
    "The time is #{Time.now.strftime("%I:%M %p")}"
  end
end
