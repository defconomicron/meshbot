($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Greetings.new.msg if /^(hello|hi)$/i =~ args[:payload]}
class Greetings
  def initialize
  end

  def msg
    [
      'Hey!',
      'Hello!',
      'Hi!',
      'Boop.. Beep.. Poop...',
      "Hello! Welcome to this-here channel. Please enjoy your stay and remember to be nice.",
      "Hey!! Come on in the water's fine!",
      'Howdy!',
      'Welcome to this-here channel!',
    ].sample
  end
end