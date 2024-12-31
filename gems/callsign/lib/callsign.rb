($COMMAND_KEYWORDS ||=[]) << '@callsign'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Callsign.new(callsign: args[:params_str]).msg if /^@callsign/i =~ args[:payload]}
class Callsign
  def initialize(options)
    @callsign = options[:callsign]
    @url = "https://callook.info/#{@callsign}/json"
  end

  def msg
    return 'A call sign must be provided with your request.  Example: @callsign KD5EF' if @callsign.blank?
    response = JSON.parse(`curl #{@url}`)
    current = response['current'] rescue {}
    current_callsign = current['callsign'] rescue nil
    current_oper_class = current['operClass'] rescue nil
    previous = response['previous'] rescue {}
    previous_callsign = previous['callsign'] rescue nil
    previous_oper_class = previous['operClass'] rescue nil
    other_info_uls_url = response['otherInfo']['ulsUrl'] rescue nil
    tokens = []
    tokens << "#{current_callsign} is a big time #{current_oper_class} class amateur radio operator!"
    tokens << "This operator was previously known as #{previous_callsign}" if previous_callsign.present?
    tokens << "For more information on this operator visit: #{other_info_uls_url}" if other_info_uls_url.present?
    tokens
  rescue Exception => e
    $tx_bot.log e, :red
  end
end
