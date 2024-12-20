class MessageQueue
  attr_accessor :messages

  def initialize
    @messages = []
  end

  def start
    Thread.new {
      while true
        message = @messages.shift
        if message.nil?
          sleep 1
          next
        end
        text = message[:text]
        bot = message[:bot]
        channel = message[:channel]
        begin
          name = bot.tx_name
          host = bot.tx_host
          ch_index = channel
          text = text.split("\n").
            join(' ').
            truncate(228). # NOTE: Max string size is 231 characters
            gsub(/\"/, "'").
            gsub(/[^\w\s\.\?\!\'\:\-\;\/\@\=]/, '')
          sent = false
          tries = 5
          $log_it.log "[#{name}] SENDING: #{text}", :green
          while !sent && tries > 0
            f = IO.popen("meshtastic --host #{host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{text}\"")
            lines = f.readlines
            f.close
            sent = !(lines.last =~ /timed out/i) rescue false
            $log_it.log("[#{name}] FAILED: #{lines.join("\n")}", :red) if !sent
            tries -= 1
            $log_it.log("[#{name}] RETRYING...", :yellow) if !sent && tries > 0
          end
          $log_it.log("[#{name}] SUCCESS!", :green) if sent
          $log_it.log("[#{name}] ABORTED!", :red) if !sent
        rescue Exception => e
          $log_it.log "[#{name}] EXCEPTION: #{e}: #{e.backtrace}", :red
        end
      end
    }
    self
  end
end
