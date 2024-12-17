($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Test.new.msg if /^test/i =~ args[:payload]}
class Test
  def initialize
  end

  def msg
    [
      'Your test message was received by me! :)',
      'Got your test message!',
      "You're loud and clear over here!"
    ].sample
  end
end