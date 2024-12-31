($COMMAND_KEYWORDS ||=[]) << '@reboot'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Reboot.new.msg if /^@reboot/i =~ args[:payload]}
class Reboot
  def initialize
  end

  def msg
    Thread.new {sleep 30;MeshtasticCli.new(host: $rx_bot.host).reboot;MeshtasticCli.new(host: $tx_bot.host).reboot}
    'Rebooting...'
  end
end