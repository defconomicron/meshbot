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
    str = []
    str << "short_name = #{short_name}" if short_name.present?
    str << "long_name = #{long_name}" if long_name.present?
    str << "hw_model = #{hw_model}" if hw_model.present?
    str << "macaddr = #{macaddr}" if macaddr.present?
    str << "last_heard = #{Time.at(last_heard.to_i).human}" if last_heard.present?
    str << "snr = #{snr}" if snr.present?
    str << "uptime_seconds = #{uptime_seconds}" if uptime_seconds.present?
    str << "battery_level = #{battery_level}" if battery_level.present?
    str << "voltage = #{voltage}" if voltage.present?
    str << "channel_utilization = #{channel_utilization}" if channel_utilization.present?
    str << "air_util_tx = #{air_util_tx}" if air_util_tx.present?
    str << "hops_away = #{hops_away}" if hops_away.present?
    str << "latitude_i = #{latitude_i}" if latitude_i.present?
    str << "longitude_i = #{longitude_i}" if longitude_i.present?
    slices = []
    str.each_slice(7).each do |_slice|
      slices << _slice.join(' | ').strip
    end
    slices
  end
end
