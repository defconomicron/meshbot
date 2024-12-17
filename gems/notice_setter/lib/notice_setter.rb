($COMMAND_KEYWORDS ||=[]) << '@notice'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeSetter.new(args[:params_arr][0], [args[:params_arr][1..-1]].compact.flatten.join(' ')).set if /^@notice/i =~ args[:payload]}
class NoticeSetter
  def initialize(number, msg)
    @number = number
    @msg = msg
  end

  def set
    return "There are #{Notice.count} of 3 notices currently set." if @number.blank?
    notice = Notice.where(number: @number.to_i).first_or_initialize
    return (notice.message.present? ? notice.message : "Notice #{@number} not currently set.") if @msg.blank?
    return (notice.destroy ? "Notice #{@number} has been deleted" : notice.errors.to_a.join(' ')) if @msg == 'delete'
    notice.message = @msg
    notice.save ? "Notice #{@number} set to: #{@msg}" : notice.errors.to_a.join(' ')
  end
end