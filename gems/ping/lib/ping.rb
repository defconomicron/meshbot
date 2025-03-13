($COMMAND_KEYWORDS ||= []) << '@ping'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Ping.new.msg if /^@ping/i =~ args[:payload]}
class Ping
  def initialize
  end

  def msg
    'pong!'
  end
end