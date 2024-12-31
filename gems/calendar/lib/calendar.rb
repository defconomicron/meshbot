($COMMAND_KEYWORDS ||=[]) << '@date'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Calendar.new.msg if /^@date/i =~ args[:payload]}
class Calendar
  def initialize
  end

  def msg
    "The date is #{Time.now.strftime("%m-%d-%Y")}"
  end
end