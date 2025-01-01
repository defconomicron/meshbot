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
    snr = nodeinfo_snapshot['snr'] rescue nil
    last_heard = nodeinfo_snapshot['last_heard'] rescue nil
    battery_level = nodeinfo_snapshot['device_metrics']['battery_level'] rescue nil
    uptime_seconds = nodeinfo_snapshot['device_metrics']['uptime_seconds'] rescue nil
    voltage = nodeinfo_snapshot['device_metrics']['voltage'] rescue nil
    channel_utilization = nodeinfo_snapshot['device_metrics']['channel_utilization'] rescue nil
    air_util_tx = nodeinfo_snapshot['device_metrics']['air_util_tx'] rescue nil
    hops_away = nodeinfo_snapshot['hops_away'] rescue nil
    latitude_i = nodeinfo_snapshot['position']['latitude_i'] rescue nil
    longitude_i = nodeinfo_snapshot['position']['longitude_i'] rescue nil
    str1 = []
    str1 << "short_name = #{short_name}" if short_name.present?
    str1 << "long_name = #{long_name}" if long_name.present?
    str1 << "hw_model = #{hw_model}" if hw_model.present?
    str1 << "macaddr = #{macaddr}" if macaddr.present?
    str1 << "last_heard = #{Time.at(last_heard.to_i).human}" if last_heard.present?
    str1 << "snr = #{snr}" if snr.present?
    str1 << "uptime = #{uptime_seconds}" if uptime_seconds.present?
    str2 = []
    str2 << "battery_level = #{battery_level}" if battery_level.present?
    str2 << "voltage = #{voltage}" if voltage.present?
    str2 << "channel_utilization = #{channel_utilization}" if channel_utilization.present?
    str2 << "air_util_tx = #{air_util_tx}" if air_util_tx.present?
    str2 << "hops_away = #{hops_away}" if hops_away.present?
    str2 << "latitude_i = #{latitude_i}" if latitude_i.present?
    str2 << "longitude_i = #{longitude_i}" if longitude_i.present?
    [
      str1.join(' | ').strip,
      str2.join(' | ').strip
    ]
  end
end
