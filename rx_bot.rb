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
      time_now = Time.now
      node = Node.where(number: num.presence || from).first_or_initialize
      next if node.ignore?
      if packet.keys.include?('user')
        nodeinfo_snapshot = packet.to_json
        log "RX: #{nodeinfo_snapshot}", :blue
        node.attributes = {nodeinfo_snapshot: nodeinfo_snapshot, updated_at: time_now}
      end
      if packet.keys.include?('user')
        user_snapshot = packet['user'].to_json
        log "RX: #{user_snapshot}", :blue
        node.attributes = {user_snapshot: user_snapshot, updated_at: time_now}
      end
      if packet.keys.include?('position')
        position_snapshot = packet['position'].to_json
        log "RX: #{position_snapshot}", :blue
        node.attributes = {position_snapshot: position_snapshot, updated_at: time_now}
      end
      if packet.keys.include?('device_metrics')
        device_metrics_snapshot = packet['device_metrics'].to_json
        log "RX: #{device_metrics_snapshot}", :blue
        node.attributes = {device_metrics_snapshot: device_metrics_snapshot, updated_at: time_now}
      end
      node.save
      if packet.keys.include?('decoded')
        channel = packet['channel'] rescue nil
        decoded = packet['decoded'] rescue nil
        payload = decoded['payload'] rescue nil
        log "RX: #{packet}", :blue
        Message.create(channel: channel, node_id: node.id, message: payload)
        payload = "#{payload}".strip
        params_arr = [payload.split(' ')[1..-1]].compact.flatten
        params_str = params_arr.join(' ')
        $TEXT_MESSAGE_HANDLERS.each {|proc|
          text = proc.call(bot: self, payload: payload, params_arr: params_arr, params_str: params_str, from: from, channel: channel, node: node)
          $tx_bot.send_text(text, channel) if text.present?
        }
      end
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
