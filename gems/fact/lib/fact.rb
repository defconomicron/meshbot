($COMMAND_KEYWORDS ||=[]) << '@fact'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Fact.new.msg if /^@fact/i =~ args[:payload]}
class Fact
  def initialize
    @url = 'https://uselessfacts.jsph.pl/api/v2/facts/random'
  end

  def msg
    response = JSON.parse(`curl #{@url}`)
    response['text'].strip
  rescue Exception => e
    $tx_bot.log e, :red
  end
end
