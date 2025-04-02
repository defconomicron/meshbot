class MessageTransmitter
  def initialize
    raise Exception.new('settings.yml not defined') if $settings.blank?
    @meshtastic_path = $settings['meshtastic']['path'] rescue nil
    raise Exception.new('meshtastic => path not defined') if @meshtastic_path.blank?
    @host = $settings['host'] rescue nil
    raise Exception.new('host not defined') if @host.blank?
  end

  def transmit(ch_index: nil, message: nil)
    raise Exception.new('ch_index not defined') if ch_index.blank?
    $message_receiver.hold = true
    begin
      $message_receiver.kill
    rescue
      $log_it.log "Trying to kill message receiver again...", :yellow
      retry
    end
    @tries = 2
    begin
      cmd = "#{@meshtastic_path} --host #{@host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{message}\""
      $log_it.log cmd, :yellow
      `#{cmd}`
    rescue Exception => e
      $log_it.log "MessageTransmitter: #{e} #{e.backtrace}", :yellow
      if @tries > 0
        @tries -= 1
        retry
      end
    end
    $message_receiver.hold = false
    self
  end
end