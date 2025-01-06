($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Test.new.msg if /^test$/i =~ args[:payload]}
class Test
  def initialize
  end

  def msg
    [
      # 'Your test message was received by me! :)',
      # 'Got your test message!',
      'Sounding good over here!',
      'I got your message over here!',
      'You are totally 5/9 over here atm! Roger, roger?',
      "You're loud and clear over here!"
    ].sample
  end
end