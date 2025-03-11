($COMMAND_KEYWORDS ||=[]) << '@notice'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeManager.new(ch_index: args[:ch_index]).help if /^@notice/i =~ args[:payload] && args[:params_arr][0].blank?}
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeManager.new(ch_index: args[:ch_index]).info if /^@notice/i =~ args[:payload] && args[:params_arr][0] == 'info'}
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeManager.new(ch_index: args[:ch_index]).all if /^@notice/i =~ args[:payload] && args[:params_arr][0] == 'all'}
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeManager.new(ch_index: args[:ch_index], number: args[:params_arr][0]).get if /^@notice/i =~ args[:payload] && args[:params_arr][0].to_s.is_integer? && args[:params_arr][1].blank?}
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeManager.new(ch_index: args[:ch_index], number: args[:params_arr][0], message: args[:params_arr][1..-1].try(:join, ' ').to_s).set if /^@notice/i =~ args[:payload] && args[:params_arr][0].to_s.is_integer? && args[:params_arr][1].present? && args[:params_arr][1] != 'delete'}
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| NoticeManager.new(ch_index: args[:ch_index], number: args[:params_arr][0]).del if /^@notice/i =~ args[:payload] && args[:params_arr][0].to_s.is_integer? && args[:params_arr][1] == 'delete'}

class NoticeManager
  def initialize(options)
    @ch_index = options[:ch_index]
    @number = options[:number]
    @message = options[:message]
  end

  def help # @notice
    "@notice, @notice info, @notice all, @notice 1, @notice 1 hello world, @notice 1 delete"
  end

  def info # @notice info
    "There are #{Notice.where(ch_index: @ch_index).count} of 3 notices currently set."
  end

  def all # @notice all
    notices = Notice.where(ch_index: @ch_index).order('number asc')
    return 'No notices currently set!' if notices.empty?
    notices.each {|notice| $tx_bot.send_text(notice.message, @ch_index)}
    nil
  end

  def get # @notice 1
    notice = Notice.where(ch_index: @ch_index, number: @number).last
    return "Notice #{@number} not currently set." if notice.nil?
    notice.message
  end

  def set # @notice 1 alpha
    notice = Notice.where(ch_index: @ch_index, number: @number).first_or_initialize
    notice.message = @message
    notice.save ? "Notice #{@number} set to: #{@message}" : notice.errors.to_a.join(' ')
  end

  def del # @notice 1 delete
    notice = Notice.where(ch_index: @ch_index, number: @number).first_or_initialize
    notice.destroy ? "Notice #{@number} has been deleted" : notice.errors.to_a.join(' ')
  end
end