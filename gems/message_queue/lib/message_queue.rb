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
        str = message[:str]
        bot = message[:bot]
        channel = message[:channel]
        begin
          name = bot.tx_name
          host = bot.tx_host
          ch_index = channel
          text = str.split("\n").join(' ').truncate(228) # NOTE: Max string size is 231 characters
          sent = false
          tries = 5
          while !sent && tries > 0
            $log_it.log "[#{name}] TX: #{text}", :green
            f = IO.popen("meshtastic --host #{host} --ch-index #{ch_index} --ack --sendtext \"#{text}\"")
            lines = f.readlines
            f.close
            timed_out = (lines.last =~ /Timed out/i) rescue false
            sent = !timed_out
            $log_it.log("[#{name}] TIMEOUT: #{lines.join("\n")}", :red) if timed_out
            tries -= 1
          end
          $log_it.log "[#{name}] INFO: Whew! I'm tired.  I'm going to sleep...", :yellow
          sleep 10
          $log_it.log "[#{name}] INFO: Ok I'm awake again!", :yellow
        rescue Exception => e
          $log_it.log "[#{name}] EXCEPTION: #{e}: #{e.backtrace}", :red
        end
      end
    }
    self
  end
end
