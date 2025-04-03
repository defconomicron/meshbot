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
    log "Placing MessageReceiver on hold..."
    $message_receiver.hold = true
    begin
      log "Killing MessageReceiver..."
      $message_receiver.kill
    rescue
      log "Attempting to kill MessageReceiver again..."
      retry
    end
    @tries = 2
    begin
      cmd = "#{@meshtastic_path} --host #{@host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{message}\""
      log cmd, :yellow
      `#{cmd}`
    rescue Exception => e
      log "MessageTransmitter: #{e} #{e.backtrace}", :red
      if @tries > 0
        @tries -= 1
        retry
      end
    end
    log "Releasing MessageReceiver hold..."
    $message_receiver.hold = false
    self
  end

  private

    def log(text, color = nil)
      $log_it.log "MessageTransmitter: #{text}", color
    end
end