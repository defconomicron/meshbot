($COMMAND_KEYWORDS ||=[]) << '@recall'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Recall.new.msg if /^@recall/i =~ args[:payload]}
class Recall
  def initialize
  end

  def msg
  end
end
