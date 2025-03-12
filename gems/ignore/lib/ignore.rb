($COMMAND_KEYWORDS ||=[]) << '@ignore'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Ignore.new(args[:params_str]).set if /^@ignore/i =~ args[:payload]}
class Ignore
  def initialize(str)
    @str = "#{str}".strip
  end

  def set
    msgs = []
    return 'A keyword must be provided with your request.  Example: @ignore bob' if @str.blank?
    nodes = Node.where('long_name like ? or short_name like ? or number like ?', "%#{@str}%", "%#{@str}%", "%#{@str}%")
    return "No nodes with keyword \"#{@str}\"" if nodes.empty?
    nodes.each do |node|
      node.ignored_at = Time.now
      msgs << "#{node.name} has been ignored." if node.save
    end
    msgs.join(' ')
  end
end
