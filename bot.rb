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
      next if !packet.is_a?(Hash)
      $log_it.log "[#{@rx_name}] RX: #{packet}"
      num = packet['num'] rescue nil
      from = packet['from'] rescue nil
      channel = packet['channel'] rescue nil
      decoded = packet['decoded'] rescue nil
      payload = decoded['payload'] rescue nil
      time_now = Time.now
      if packet.keys.include?('user')
        $log_it.log "user: #{packet}"
        node = Node.where(number: num).first_or_initialize
        next if node.ignore?
        node.attributes = {nodeinfo_snapshot: packet.to_json, updated_at: time_now}
        node.save
      elsif packet.keys.include?('position')
        $log_it.log "position: #{packet}"
        node = Node.where(number: num).first_or_initialize
        next if node.ignore?
        node.attributes = {position_snapshot: packet.to_json, updated_at: time_now}
        node.save
      elsif packet.keys.include?('device_metrics')
        $log_it.log "device_metrics: #{packet}"
        node = Node.where(number: num).first_or_initialize
        next if node.ignore?
        node.attributes = {telemetry_snapshot: packet.to_json, updated_at: time_now}
        node.save
      elsif packet.keys.include?('decoded')
        $log_it.log "decoded: #{packet}"
        node = Node.where(number: from).first_or_initialize
        next if node.ignore?
        payload = "#{payload}".strip
        params_arr = [payload.split(' ')[1..-1]].compact.flatten
        params_str = params_arr.join(' ')
        $TEXT_MESSAGE_HANDLERS.each {|proc|
          text = proc.call(bot: self, payload: payload, params_arr: params_arr, params_str: params_str, from: from, channel: channel)
          send_text(text, channel)
        }
        node.save
      end
    end
  rescue Exception => e
    $log_it.log "[#{@rx_name}] EXCEPTION: #{e}: #{e.backtrace}", :red
  end

  def send_text(text, channel)
    return if text.nil? || text.length == 0
    @message_queue.messages << {bot: self, text: text, channel: channel}
  end
end
# telemetry
# {"packet"=>{"num"=>2718567968, "snr"=>6.5, "last_heard"=>1734493431, "device_metrics"=>{"battery_level"=>101, "voltage"=>0, "channel_utilization"=>2.24333334, "air_util_tx"=>0.0186944436, "uptime_seconds"=>54}}}
# position
# {"packet"=>{"num"=>1129898244, "position"=>{"latitude_i"=>354549760, "longitude_i"=>-976355328, "altitude"=>372, "time"=>1734496726, "location_source"=>"LOC_MANUAL"}}}
# nodeinfo
# {"packet"=>{"num"=>1128178176, "user"=>{"id"=>"!433ea200", "long_name"=>"KA5ECX MOBILE 1", "short_name"=>"ECX1", "macaddr"=>"H312C>242000", "hw_model"=>"HELTEC_V3", "public_key"=>"260013%376247*374304e234324013037)211021n025006204201\t<371313jF023227r=Q"}}}
# text
# {"packet"=>{"from"=>3324404670, "to"=>4294967295, "channel"=>2, "decoded"=>{"portnum"=>"TEXT_MESSAGE_APP", "payload"=>"okok", "bitfield"=>1}}}
