($COMMAND_KEYWORDS ||=[]) << '@recall'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Recall.new(requester_node: args[:node], channel: args[:channel], keyword: args[:params_arr].join('%')).msg if /^@recall/i =~ args[:payload]}
class Recall
  def initialize(options)
    @channel = options[:channel]
    @keyword = options[:keyword]
    @requester_node = options[:requester_node]
  end

  def msg
    rx_bot_node = Node.where(short_name: $rx_bot.name).last
    message = Message.where(channel: @channel).where('message like ? and node_id != ? and node_id != ?', "%#{@keyword}%", @requester_node.id, rx_bot_node.id).last
    message.nil? ? "No messages found matching: %#{@keyword}%" : "#{message.node.long_name.presence || "Node ##{message.node.number}"}: #{message.message}"
  end
end
