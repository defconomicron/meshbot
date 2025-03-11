($COMMAND_KEYWORDS ||=[]) << '@seen'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Seen.new(args[:params_str]).msg if /^@seen/i =~ args[:payload]}
class Seen
  def initialize(str)
    @str = "#{str}".strip
  end

  def msg
    return 'A keyword must be provided with your request.  Example: @seen bob' if @str.blank?
    node = Node.where('long_name like ? or short_name like ?', "%#{@str}%", "%#{@str}%").last
    node.present? ? "#{node.name} was last seen on #{node.updated_at.human}" : "Sorry!! I haven't seen #{@str}."
  end
end