($COMMAND_KEYWORDS ||=[]) << '@about'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| About.new.msg if /^@about/i =~ args[:payload]}
class About
  def initialize
  end

  def msg
    "Oh hai!  I'm a service droid that was built by ADAM - KD5EF.  For more information on what commands I have, type: @help"
  end
end