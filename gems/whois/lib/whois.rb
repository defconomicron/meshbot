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
    telemetry_snapshot = JSON.parse(node.telemetry_snapshot) rescue {}
    uptime_seconds = telemetry_snapshot['device_metrics']['uptime_seconds'] rescue nil
    battery_level = telemetry_snapshot['device_metrics']['battery_level'] rescue nil
    last_heard = telemetry_snapshot['last_heard'] rescue nil
    snr = telemetry_snapshot['snr'] rescue nil
    str = []
    str << "#{short_name}: #{long_name} is running a #{hw_model} with a MAC address of #{macaddr}"
    str << "and was heard on #{Time.at(last_heard.to_i).strftime('%m-%d-%Y at %H:%M:%S %p')}" if last_heard.present?
    str << "with a SNR of #{snr}" if snr.present?
    str << "Node's uptime is #{uptime_seconds} seconds and current battery level is #{battery_level}%." if uptime_seconds.present? && battery_level.present?
    str.join(' ').strip
  end
end
