($COMMAND_KEYWORDS ||=[]) << '@chuck'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Chuck.new.msg if /^@chuck/i =~ args[:payload]}
class Chuck
  def initialize
    @url = 'https://api.chucknorris.io/jokes/random'
  end

  def msg
    response = JSON.parse(`curl #{@url}`)
    response['value'].strip
  rescue Exception => e
    $tx_bot.log e, :red
  end
end
