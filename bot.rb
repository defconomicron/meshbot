class Bot
  attr_accessor :thread, :rx_name, :rx_host, :tx_name, :tx_host

  def initialize(options={})
    $log_it.log 'Starting up!!!', :green
    @thread        = nil
    @rx_name       = options[:rx_name]
    @rx_host       = options[:rx_host]
    @tx_name       = options[:tx_name]
    @tx_host       = options[:tx_host]
    @message_queue = MessageQueue.new.start
    $log_it.log 'Done!', :green
  end

  def monitor
    MeshtasticCli.new(host: @rx_host, name: @rx_name).packets do |packet|
      $log_it.log "[#{@rx_name}] RX: #{packet}"
      from = packet['from'] rescue nil
      channel = packet['channel'] rescue nil
      decoded = packet['decoded'] rescue nil
      portnum = decoded['portnum'] rescue nil
      payload = decoded['payload'] rescue nil
      bitfield = decoded['bitfield'] rescue nil
      time_now = Time.now
      node = Node.where(number: from).first_or_initialize
      next if node.ignore?
      case portnum
        when 'POSITION_APP'
          node.attributes = {position_snapshot: packet, updated_at: time_now}
        when 'TELEMETRY_APP'
          node.attributes = {telemetry_snapshot: packet, updated_at: time_now}
        when 'NODEINFO_APP'
          node.attributes = {nodeinfo_snapshot: packet, updated_at: time_now}
        when 'TEXT_MESSAGE_APP'
          payload = "#{payload}".strip
          params_arr = [payload.split(' ')[1..-1]].compact.flatten
          params_str = params_arr.join(' ')
          $TEXT_MESSAGE_HANDLERS.each {|proc|
            text = proc.call(bot: self, payload: payload, params_arr: params_arr, params_str: params_str, from: from, channel: channel)
            send_text(text, channel)
          }
      end
      node.save
    end
  rescue Exception => e
    $log_it.log "[#{@rx_name}] EXCEPTION: #{e}: #{e.backtrace}", :red
  end

  def send_text(text, channel)
    return if text.nil? || text.length == 0
    @message_queue.messages << {bot: self, text: text, channel: channel}
  end
end
