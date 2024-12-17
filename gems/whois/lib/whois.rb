($COMMAND_KEYWORDS ||=[]) << '@whois'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Whois.new(args[:params_str]).msg if /^@whois/i =~ args[:payload]}
# {:packet=>{:from=>3132410228, :to=>4294967295, :channel=>8, :id=>1956019094, :rx_time=>1733284334, :rx_snr=>-14.5, :hop_limit=>0, :want_ack=>false, :priority=>:UNSET, :rx_rssi=>-124, :delayed=>:NO_DELAY, :via_mqtt=>false, :hop_start=>4, :decoded=>{:portnum=>:NODEINFO_APP, :payload=>{:id=>"!bab4c974", :long_name=>"Beaufort", :short_name=>"BFRT", :macaddr=>"e8:9c:ba:b4:c9:74", :hw_model=>:RAK4631, :is_licensed=>false, :role=>:ROUTER}, :want_response=>false, :dest=>0, :source=>0, :request_id=>0, :reply_id=>0, :emoji=>0}, :encrypted=>:decrypted, :topic=>"msh/US/OK/2/e/LongFast/!da5cc71c", :node_id_from=>"!bab4c974", :node_id_to=>"!ffffffff", :rx_time_utc=>"2024-12-04 03:52:14 UTC"}, :channel_id=>"LongFast", :gateway_id=>"!da5cc71c"}
class Whois
  def initialize(str)
    @str = "#{str}".strip
  end

  def msg
    return 'A keyword must be provided with your request.  Example: @whois bob' if @str.blank?
    node = Node.where('long_name like ? or short_name like ?', "%#{@str}%", "%#{@str}%").last
    if node.nil?
      "Sorry!! I don't know who #{@str} is."
    else
      nodeinfo_snapshot = JSON.parse(node.nodeinfo_snapshot) rescue {}
      short_name = nodeinfo_snapshot['decoded']['payload']['short_name'] rescue nil
      long_name = nodeinfo_snapshot['decoded']['payload']['long_name'] rescue nil
      hw_model = nodeinfo_snapshot['decoded']['payload']['hw_model'] rescue nil
      macaddr = nodeinfo_snapshot['decoded']['payload']['macaddr'] rescue nil
      rx_time = nodeinfo_snapshot['rx_time'] rescue nil
      rx_snr = nodeinfo_snapshot['rx_snr'] rescue nil
      rx_rssi = nodeinfo_snapshot['rx_rssi'] rescue nil
      via_mqtt = nodeinfo_snapshot['via_mqtt'] rescue nil
      str = []
      str << "#{short_name}: #{long_name} is running a #{hw_model} with a MAC address of #{macaddr} and was heard on #{Time.at(rx_time.to_i).strftime('%m-%d-%Y at %H:%M:%S %p')}"
      str << (via_mqtt ? 'via MQTT.' : "with a SNR of #{rx_snr} and an RSSI of #{rx_rssi} via LoRa.")
      telemetry_snapshot = JSON.parse(node.telemetry_snapshot) rescue {}
      if telemetry_snapshot.present?
        uptime_seconds = telemetry_snapshot['decoded']['payload']['device_metrics']['uptime_seconds']
        battery_level = telemetry_snapshot['decoded']['payload']['device_metrics']['battery_level']
        str << "Node's uptime is #{uptime_seconds} seconds and current battery level is #{battery_level}%."
      end
      position_snapshot = JSON.parse(node.position_snapshot) rescue {}
      if position_snapshot.present?
      end
      str.join(' ').strip
    end
  end
end
