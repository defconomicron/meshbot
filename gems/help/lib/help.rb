($COMMAND_KEYWORDS ||=[]) << '@help'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Help.new.msg if /^@help/i =~ args[:payload]}
class Help
  def initialize
  end

  def msg
    "Greetings human!  I am a service droid.  Hear me r0ar!  My commands are: " << $COMMAND_KEYWORDS.join(', ')
  end
end