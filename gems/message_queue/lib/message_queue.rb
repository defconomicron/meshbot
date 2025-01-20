class MessageQueue
  attr_accessor :messages

  def initialize
    log 'MESSAGE QUEUE INITIALIZING...', :yellow
    @messages = []
  end

  def start
    Thread.new {
      log 'MESSAGE QUEUE RUNNING!', :yellow
      $keep_alive_pid = nil
      if $tx_bot.nil?
        log 'ERROR: $tx_bot must be defined before MessageQueue can start.', :red
        exit
      end
      while true
        if $keep_alive_pid.nil? && @messages.empty?
          log 'KEEP-ALIVE ROUTINE INITIALIZING...', :yellow
          Thread.new {
            PTY.spawn("#{$meshtastic_path} --host #{$tx_bot.host} --listen") do |stdout, stdin, pid|
              $keep_alive_pid = pid
              stdout.each {|line|} rescue nil
            end
          }
          log 'KEEP-ALIVE ROUTINE RUNNING!', :yellow
        end
        message = @messages.shift
        if message.nil?
          sleep 1
          next
        end
        if $keep_alive_pid.present?
          `kill -9 #{$keep_alive_pid}`
          $keep_alive_pid = nil
          log 'KEEP-ALIVE ROUTINE KILLED!', :yellow
        end
        log "TX CH-#{message[:ch_index]} SENDING: #{message[:text]}", :green
        tries = 5
        ch_index = message[:ch_index]
        begin
          text = message[:text].split("\n").
            join(' ').
            truncate(228). # NOTE: Max string size is 231 characters
            gsub(/\"/, "'")
          text = Censor.new(text).apply
          f = IO.popen("#{$meshtastic_path} --host #{$tx_bot.host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{text}\"")
          response = f.readlines.join("\n")
          f.close
          log "MESH_CLI: #{response}"
          tries = 0 if response =~ /data payload too big/i
          sent = response =~ /received an implicit ack/i
          raise Exception.new(response) if !sent
          log "TX CH-#{ch_index} SENT!", :green
        rescue Exception => e
          log "TX CH-#{ch_index} EXCEPTION: #{e}: #{e.backtrace}", :red
          if tries > 0
            tries -= 1
            log "TX CH-#{ch_index} RETRYING...", :yellow
            retry
          else
            log "TX CH-#{ch_index} ABORTED!", :red
          end
        end
      end
    }
    self
  end

  def log(text, color=nil)
    ($tx_bot || $log_it).log(text, color)
  end
end
