($COMMAND_KEYWORDS ||=[]) << '@whois'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Whois.new(args[:params_str]).msg if /^@whois/i =~ args[:payload]}
class Whois
  def initialize(str)
    @str = "#{str}".strip
  end

  def msg
    return 'A keyword must be provided with your request.  Example: @whois bob' if @str.blank?
    node = Node.where('long_name like ? or short_name like ?', "%#{@str}%", "%#{@str}%").last
    return "Sorry!! I don't know who #{@str} is." if node.nil?
    nodeinfo_snapshot = JSON.parse(node.nodeinfo_snapshot) rescue {}
    short_name = nodeinfo_snapshot['user']['short_name'] rescue nil
    long_name = nodeinfo_snapshot['user']['long_name'] rescue nil
    hw_model = nodeinfo_snapshot['user']['hw_model'] rescue nil
    macaddr = nodeinfo_snapshot['user']['macaddr'] rescue nil
    # rx_time = nodeinfo_snapshot['rx_time'] rescue nil
    # rx_snr = nodeinfo_snapshot['rx_snr'] rescue nil
    # rx_rssi = nodeinfo_snapshot['rx_rssi'] rescue nil
    # via_mqtt = nodeinfo_snapshot['via_mqtt'] rescue nil
    str = []
    str << "#{short_name}: #{long_name} is running a #{hw_model} with a MAC address of #{macaddr} and was heard on #{Time.at(rx_time.to_i).strftime('%m-%d-%Y at %H:%M:%S %p')}"
    # str << (via_mqtt ? 'via MQTT.' : "with a SNR of #{rx_snr} and an RSSI of #{rx_rssi} via LoRa.")
    # telemetry_snapshot = JSON.parse(node.telemetry_snapshot) rescue {}
    # if telemetry_snapshot.present?
    #   uptime_seconds = telemetry_snapshot['decoded']['payload']['device_metrics']['uptime_seconds']
    #   battery_level = telemetry_snapshot['decoded']['payload']['device_metrics']['battery_level']
    #   str << "Node's uptime is #{uptime_seconds} seconds and current battery level is #{battery_level}%."
    # end
    # position_snapshot = JSON.parse(node.position_snapshot) rescue {}
    # if position_snapshot.present?
    # end
    str.join(' ').strip
  end
end
