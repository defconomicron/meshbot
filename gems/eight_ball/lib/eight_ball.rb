($COMMAND_KEYWORDS ||=[]) << '@8ball'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| EightBall.new(args[:params_str]).msg if /^@8ball/i =~ args[:payload]}
class EightBall
  def initialize(question)
    @question = question
  end

  def msg
    return 'You must include a question when using @8ball' if @question.nil? || @question.length == 0
    answers = [
      'It is certain',
      'Reply hazy',
      'Try again',
      "Don't count on it",
      'It is decidedly so',
      'Ask again later',
      'My reply is no',
      'Without a doubt',
      'Better not tell you now',
      'My sources say no',
      'Yes definitely',
      'Cannot predict now',
      'Outlook not so good',
      'You may rely on it',
      'Concentrate and ask again',
      'Very doubtful',
      'As I see it, yes',
      'Most likely',
      'Outlook good',
      'Yes',
      'Signs point to yes'
    ]
    'Magic 8 ball reads: ' << answers.sample
  end
end