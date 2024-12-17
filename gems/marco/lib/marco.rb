($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Marco.new.msg if /^marco$/i =~ args[:payload]}
class Marco
  def initialize
  end

  def msg
    'POLO!'
  end
end