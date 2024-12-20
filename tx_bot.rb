class TxBot
  attr_accessor :thread, :name, :host, :message_queue

  def initialize(options={})
    @name = options[:name]
    log "Starting up!!!", :green
    @thread = nil
    @host = options[:host]
    log "Done!", :green
  end

  def monitor
    @message_queue = MessageQueue.new.start
  end

  def send_text(text, channel)
    return if text.nil? || text.length == 0
    @message_queue.messages << {text: text, channel: channel}
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end
end