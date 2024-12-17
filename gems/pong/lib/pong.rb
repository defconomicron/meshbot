($COMMAND_KEYWORDS ||=[]) << '@ping'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Pong.new.msg if /^@ping/i =~ args[:payload]}
class Pong
  def initialize
  end

  def msg
    'pong!'
  end
end