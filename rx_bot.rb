class RxBot
  attr_accessor :name, :host

  def initialize(options={})
    @name = options[:name]
    log "Starting up!!!", :green
    @host = options[:host]
    log "Done!", :green
  end

  def monitor
    MeshtasticCli.new(host: @host, name: @name).packets do |packet|
      next if !packet.is_a?(Hash)
      num = packet['num'] rescue nil
      from = packet['from'] rescue nil
      channel = packet['channel'] rescue nil
      decoded = packet['decoded'] rescue nil
      payload = decoded['payload'] rescue nil
      time_now = Time.now
      node = Node.where(number: num.presence || from).first_or_initialize
      next if node.ignore?
      if packet.keys.include?('user')
        log "RX: #{packet}", :blue
        node.attributes = {nodeinfo_snapshot: packet.to_json, updated_at: time_now}
      elsif packet.keys.include?('position')
        log "RX: #{packet}", :blue
        node.attributes = {position_snapshot: packet.to_json, updated_at: time_now}
      elsif packet.keys.include?('device_metrics')
        log "RX: #{packet}", :blue
        node.attributes = {telemetry_snapshot: packet.to_json, updated_at: time_now}
      elsif packet.keys.include?('decoded')
        log "RX: #{packet}"
        payload = "#{payload}".strip
        params_arr = [payload.split(' ')[1..-1]].compact.flatten
        params_str = params_arr.join(' ')
        $TEXT_MESSAGE_HANDLERS.each {|proc|
          text = proc.call(bot: self, payload: payload, params_arr: params_arr, params_str: params_str, from: from, channel: channel)
          $tx_bot.send_text(text, channel)
        }
      else
        log "RX: #{packet}"
      end
      node.save
    end
  rescue Exception => e
    log "EXCEPTION: #{e}: #{e.backtrace}", :red
    log "Whew! I'm going to sleep... Be back in a minute.", :yellow
    sleep 60
    log "Okay, I'm awake again and listening for new packets!", :yellow
    retry
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end
end
