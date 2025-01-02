class TxBot
  attr_accessor :thread, :name, :host, :message_queue

  def initialize(options={})
    @name = options[:name]
    log 'INITIALIZING!', :green
    @host = options[:host]
    log 'DONE!', :green
  end

  def monitor
    @message_queue = MessageQueue.new
    @message_queue.start
    self
  end

  def send_text(text, ch_index)
    return if text.blank?
    @message_queue.messages << {text: text, ch_index: ch_index}
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end
end