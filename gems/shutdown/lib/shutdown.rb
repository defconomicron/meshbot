($COMMAND_KEYWORDS ||=[]) << '@shutdown'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Shutdown.new.msg if /^@shutdown/i =~ args[:payload]}
class Shutdown
  def initialize
  end

  def msg
    Thread.new {sleep 30;exit}
    'Shutting down...'
  end
end