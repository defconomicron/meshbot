($COMMAND_KEYWORDS ||= []) << '@coin'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Coin.new.msg if /^@coin/i =~ args[:payload]}
class Coin
  def initialize
  end

  def msg
    [
      '* Flips coin into the air *',
      'The coin lands and bounces around on the ground for a few seconds, before settling on:',
      ['HEADS!', 'TAILS!'].sample
    ]
  end
end
