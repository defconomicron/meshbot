class MessageTransmitter
  def initialize
    raise Exception.new('settings.yml not defined') if SETTINGS.blank?
    @meshtastic_path = SETTINGS['meshtastic']['path'] rescue nil
    raise Exception.new('meshtastic => path not defined') if @meshtastic_path.blank?
    @host = SETTINGS['host'] rescue nil
    raise Exception.new('host not defined') if @host.blank?
  end

  def transmit(ch_index: nil, message: nil)
    raise Exception.new('ch_index not defined') if ch_index.blank?
    @tries = 2
    begin
      cmd = "#{@meshtastic_path} --host #{@host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{message}\""
      puts cmd
      `#{cmd}`
    rescue Exception => e
      puts "MessageTransmitter: #{e} #{e.backtrace}"
      if @tries > 0
        @tries -= 1
        retry
      end
    end
    self
  end
end