($COMMAND_KEYWORDS ||= []) << '@help'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Help.new.msg if /^@help/i =~ args[:payload]}
class Help
  def initialize
  end

  def msg
    commands = ['Greetings human!  I am a service droid.  Hear me r0ar!  My commands are: ']
    cmds = $COMMAND_KEYWORDS.each_slice(15).map {|batch| batch.join(', ')}
    commands[0] << cmds[0]
    commands += cmds[1..-1]
    commands
  end
end