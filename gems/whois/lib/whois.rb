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
    nodeinfo_snapshot   = JSON.parse(node.nodeinfo_snapshot) rescue {}
    telemetry_snapshot  = JSON.parse(node.telemetry_snapshot) rescue {}
    position_snapshot   = JSON.parse(node.position_snapshot) rescue {}
    short_name          = nodeinfo_snapshot['short_name'] rescue nil
    long_name           = nodeinfo_snapshot['long_name'] rescue nil
    hw_model            = nodeinfo_snapshot['hw_model'] rescue nil
    macaddr             = nodeinfo_snapshot['macaddr'] rescue nil
    rx_time             = nodeinfo_snapshot['rx_time'] rescue nil
    rx_snr              = nodeinfo_snapshot['rx_snr'] rescue nil
    rx_rssi             = nodeinfo_snapshot['rx_rssi'] rescue nil
    via_mqtt            = nodeinfo_snapshot['via_mqtt'] rescue nil
    hop_start           = nodeinfo_snapshot['hop_start'] rescue nil
    uptime_seconds      = telemetry_snapshot['uptime_seconds'] rescue nil
    battery_level       = telemetry_snapshot['battery_level'] rescue nil
    voltage             = telemetry_snapshot['voltage'] rescue nil
    channel_utilization = telemetry_snapshot['channel_utilization'] rescue nil
    air_util_tx         = telemetry_snapshot['air_util_tx'] rescue nil
    latitude            = position_snapshot['latitude'] rescue nil
    longitude           = position_snapshot['longitude'] rescue nil
    str = []
    str << "short_name = #{short_name}" if short_name.present?
    str << "long_name = #{long_name}" if long_name.present?
    str << "hw_model = #{hw_model}" if hw_model.present?
    str << "macaddr = #{macaddr}" if macaddr.present?
    str << "time = #{Time.at(rx_time.to_i).human}" if rx_time.present?
    str << "snr = #{rx_snr}" if rx_snr.present?
    str << "rssi = #{rx_rssi}" if rx_rssi.present?
    str << "via_mqtt = #{via_mqtt}" if via_mqtt.present?
    str << "hop_start = #{hop_start}" if hop_start.present?
    str << "uptime = #{uptime_seconds}" if uptime_seconds.present?
    str << "battery = #{battery_level}" if battery_level.present?
    str << "volts = #{voltage}" if voltage.present?
    str << "chan_util = #{channel_utilization}" if channel_utilization.present?
    str << "air_util_tx = #{air_util_tx}" if air_util_tx.present?
    str << "lati = #{latitude}" if latitude.present?
    str << "long = #{longitude}" if longitude.present?
    slices = []
    str.each_slice(8).each do |_slice|
      slices << _slice.join(' | ').strip
    end
    slices
  end
end
