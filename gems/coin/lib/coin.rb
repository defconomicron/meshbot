($COMMAND_KEYWORDS ||=[]) << '@coin'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Coin.new.msg if /^@coin/i =~ args[:payload]}
class Coin
  def initialize
  end

  def msg
    'Coin lands on: ' << ['heads!', 'tails!'].sample
  end
end
