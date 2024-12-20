($COMMAND_KEYWORDS ||=[]) << '@reboot'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Reboot.new.msg if /^@reboot/i =~ args[:payload]}
class Reboot
  def initialize
  end

  def msg
    Thread.new {sleep 30;MeshtasticCli.new(host: $rx_bot.host, name: $rx_bot.name).reboot}
    Thread.new {sleep 30;MeshtasticCli.new(host: $tx_bot.host, name: $tx_bot.name).reboot}
    'Rebooting...'
  end
end