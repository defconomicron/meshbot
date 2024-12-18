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
    MeshtasticCli.new(host: @rx_host, name: @rx_name).packets do |response|
      $log_it.log "[#{@rx_name}] RX: #{response}"
      # {"node_info"=>{"num"=>1128178176, "user"=>{"id"=>"!433ea200", "long_name"=>"KA5ECX MOBILE 1", "short_name"=>"ECX1", "macaddr"=>"H312C>242000", "hw_model"=>"HELTEC_V3", "public_key"=>"260013%376247*374304e234324013037)211021n025006204201\t<371313jF023227r=Q"}}}
      # {"packet"=>{"from"=>3324404670, "to"=>4294967295, "channel"=>2, "decoded"=>{"portnum"=>"TEXT_MESSAGE_APP", "payload"=>"okok", "bitfield"=>1}}}
      num = response['node_info']['num'] rescue nil
      long_name = response['node_info']['user']['long_name'] rescue nil
      short_name = response['node_info']['user']['short_name'] rescue nil
      macaddr = response['node_info']['user']['macaddr'] rescue nil
      hw_model = response['node_info']['user']['hw_model'] rescue nil
      from = response['packet']['from'] rescue nil
      channel = response['packet']['channel'] rescue nil
      decoded = response['packet']['decoded'] rescue nil
      portnum = decoded['portnum'] rescue nil
      payload = decoded['payload'] rescue nil
      bitfield = decoded['bitfield'] rescue nil
      time_now = Time.now
      case response.keys[0]
        when 'node_info'
          node = Node.where(number: num).first_or_initialize
          next if node.ignore?
          node.attributes = {nodeinfo_snapshot: response['node_info'].to_json, updated_at: time_now}
          node.save
        when 'packet'
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
