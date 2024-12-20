($COMMAND_KEYWORDS ||=[]) << '@reboot'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Reboot.new(channel: args[:channel]).msg if /^@reboot/i =~ args[:payload]}
class Reboot
  def initialize(options)
    @channel = options[:channel]
  end

  def msg
    Thread.new {
      # $rx_bot.send_text 'Rebooting...', @channel
      sleep 30;MeshtasticCli.new(host: $rx_bot.host).reboot
    }
    Thread.new {
      $tx_bot.send_text 'Rebooting...', @channel
      sleep 30;MeshtasticCli.new(host: $tx_bot.host).reboot
    }
    nil
  end
end