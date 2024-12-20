class TxBot
  attr_accessor :thread, :name, :host, :message_queue

  def initialize(options={})
    @name = options[:name]
    log "Starting up!!!", :green
    @host = options[:host]
    @thread = nil
    @message_queue = MessageQueue.new
    log "Done!", :green
  end

  def monitor
    @message_queue.start
  end

  def send_text(text, channel)
    return if text.nil? || text.length == 0
    log("TX CH-#{channel} QUEUED: #{text}", :green)
    @message_queue.messages << {text: text, channel: channel}
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end
end