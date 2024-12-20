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
        channel = message[:channel]
        begin
          name = $tx_bot.name
          host = $tx_bot.host
          ch_index = channel
          text = text.split("\n").
            join(' ').
            truncate(228). # NOTE: Max string size is 231 characters
            gsub(/\"/, "'").
            gsub(/[^\w\s\.\?\!\'\:\-\;\/\@\=\,\*]/, '')
          sent = false
          tries = 5
          $tx_bot.log "TX CH-#{ch_index} SENDING: #{text}", :green
          while !sent && tries > 0
            f = IO.popen("meshtastic --host #{host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{text}\"")
            lines = f.readlines
            f.close
            sent = !(lines.last =~ /timed out/i) rescue false
            $tx_bot.log("TX CH-#{ch_index} FAILED: #{lines.join("\n")}", :red) if !sent
            tries -= 1
            $tx_bot.log("TX CH-#{ch_index} RETRYING...", :yellow) if !sent && tries > 0
          end
          sent ? $tx_bot.log("TX CH-#{ch_index} SENT!", :green) :
                 $tx_bot.log("TX CH-#{ch_index} ABORTED!", :red)
        rescue Exception => e
          $tx_bot.log "TX CH-#{ch_index} EXCEPTION: #{e}: #{e.backtrace}", :red
        end
      end
    }
    self
  end
end
