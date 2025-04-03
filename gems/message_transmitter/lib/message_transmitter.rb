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
      cmd = "#{@meshtastic_path} --host #{@host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{sanitize(message)}\""
      log cmd, :yellow
      execute_cmd(cmd)
    rescue Exception => e
      log "#{e} #{e.backtrace}", :red
      if @tries > 0
        log "Retrying: #{cmd}"
        @tries -= 1
        retry
      end
    end
    log "Releasing MessageReceiver hold..."
    $message_receiver.hold = false
    self
  end

  private

    def execute_cmd(cmd)
      response = []
      begin
        PTY.spawn(cmd) do |stdout, stdin, pid|
          stdout.each do |line|
            log line
            response << line
          end
        end
      rescue Exception => e
        log "#{e}"
        response << "#{e}"
      end
      raise Exception.new(response.join(' ')) if error?(response.join(' '))
      response
    end

    def error?(str)
      str =~ /timed out/i ||
      str =~ /error connecting/i ||
      str =~ /connection reset/i ||
      str =~ /broken pipe/i
    end

    def log(text, color = nil)
      $log_it.log "MessageTransmitter: #{text}", color
    end

    def sanitize(str)
      "#{str}".gsub('"',"'")
    end
end