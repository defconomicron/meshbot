class RxBot
  attr_accessor :thread, :name, :host

  def initialize(options={})
    @name = options[:name]
    $log_it.log "[#{@name}] Starting up!!!", :green
    @thread = nil
    @host = options[:host]
    $log_it.log "[#{@name}] Done!", :green
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
        $log_it.log "[#{@name}] RX: #{packet}", :blue
        node.attributes = {nodeinfo_snapshot: packet.to_json, updated_at: time_now}
      elsif packet.keys.include?('position')
        $log_it.log "[#{@name}] RX: #{packet}", :blue
        node.attributes = {position_snapshot: packet.to_json, updated_at: time_now}
      elsif packet.keys.include?('device_metrics')
        $log_it.log "[#{@name}] RX: #{packet}", :blue
        node.attributes = {telemetry_snapshot: packet.to_json, updated_at: time_now}
      elsif packet.keys.include?('decoded')
        $log_it.log "[#{@name}] RX: #{packet}"
        payload = "#{payload}".strip
        params_arr = [payload.split(' ')[1..-1]].compact.flatten
        params_str = params_arr.join(' ')
        $TEXT_MESSAGE_HANDLERS.each {|proc|
          text = proc.call(bot: self, payload: payload, params_arr: params_arr, params_str: params_str, from: from, channel: channel)
          $tx_bot.send_text(text, channel)
        }
      else
        $log_it.log "[#{@name}] RX: #{packet}"
      end
      node.save
    end
  rescue Exception => e
    $log_it.log "[#{@name}] EXCEPTION: #{e}: #{e.backtrace}", :red
    $log_it.log "[#{@name}] Whew! I'm going to sleep... Be back in a minute.", :yellow
    sleep 60
    $log_it.log "[#{@name}] Okay, I'm awake again and listening for new packets!", :yellow
    retry
  end
end
