($COMMAND_KEYWORDS ||=[]) << '@info'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Info.new.msg if /^@info/i =~ args[:payload]}
class Info
  def initialize
  end

  def msg
    "Oh hai!  I'm a service droid that was built by ADAM - KD5EF.  For more information on what commands I have, type: @help"
  end
end