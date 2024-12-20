($COMMAND_KEYWORDS ||=[]) << '@coin'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Coin.new(channel: args[:channel]).msg if /^@coin/i =~ args[:payload]}
class Coin
  def initialize(options)
    @channel = options[:channel]
  end

  def msg
    $tx_bot.send_text '* Flips coin into the air *', @channel
    $tx_bot.send_text 'The coin lands and bounces around on the ground for a few seconds, before settling on:', @channel
    $tx_bot.send_text ['HEADS!', 'TAILS!'].sample, @channel
    nil
  end
end
