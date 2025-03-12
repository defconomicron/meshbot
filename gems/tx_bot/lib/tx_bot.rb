class TxBot
  attr_accessor :thread, :name, :host, :messages, :keep_alive_pid

  def initialize(options)
    @name = options[:name]
    log 'INITIALIZING...', :green
    @host = options[:host]
    @messages = []
    @keep_alive_pid = nil
    @sending_tries = $settings['sending_tries']
    log 'DONE!', :green
  end

  def monitor
    Thread.new {
      log 'MESSAGE QUEUE RUNNING!', :yellow
      while true
        initialize_keep_alive_routine
        message = get_next_message
        tries = @sending_tries
        ch_index = message[:ch_index]
        begin
          text = filter_text(message[:text])
          log "TX CH-#{ch_index} SENDING: #{text}", :green
          kill_keep_alive_routine
          send_message(ch_index, text) {|f|
            response = f.readlines.join("\n")
            log "MESH_CLI: #{response}"
            tries = 0 if fatal_error?(response)
            raise Exception.new(response) if !sent_successfully?(response)
          }
          log "TX CH-#{ch_index} SENT!", :green
        rescue Exception => e
          log "TX CH-#{ch_index} EXCEPTION: #{e}: #{e.backtrace}", :red
          if tries > 0
            tries -= 1
            log "TX CH-#{ch_index} RETRYING... [#{tries} TRIES REMAINING]", :yellow
            retry
          else
            log "TX CH-#{ch_index} ABORTED!", :red
          end
        end
      end
    }
    self
  end

  def send_text(text, ch_index)
    return if text.blank? || ch_index.blank?
    @messages << {text: text, ch_index: ch_index}
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end

  private

    def fatal_error?(response)
      !(response =~ /data payload too big/i).nil?
    end

    def sent_successfully?(response)
      !(response =~ /received an implicit ack/i).nil?
    end

    def filter_text(text)
      censor_text(normalize_text(text))
    end

    def normalize_text(text)
      text.split("\n").
        join(' ').
        truncate(228). # NOTE: Max string size is 231 characters
        gsub(/\"/, "'")
    end

    def censor_text(text)
      Censor.new(text).apply
    end

    def send_message(ch_index, text)
      IO.popen("#{$meshtastic_path} --host #{$tx_bot.host} --ch-index #{ch_index} --no-time --ack --sendtext \"#{text}\"")
    end

    def get_next_message
      while (message = @messages.shift).nil?
        sleep 1
        next
      end
      message
    end

    def initialize_keep_alive_routine
      if @keep_alive_pid.nil? && @messages.empty?
        log 'KEEP-ALIVE ROUTINE INITIALIZING...', :yellow
        Thread.new {
          log 'KEEP-ALIVE ROUTINE RUNNING!', :yellow
          PTY.spawn("#{$meshtastic_path} --host #{$tx_bot.host} --listen") do |stdout, stdin, pid|
            @keep_alive_pid = pid
            stdout.each {|line|} rescue nil
          end
        }
      end
    end

    def kill_keep_alive_routine
      if @keep_alive_pid.present?
        `kill -9 #{@keep_alive_pid}`
        @keep_alive_pid = nil
        log 'KEEP-ALIVE ROUTINE KILLED!', :yellow
      end
    end

    def ensure_tx_bot_defined
      if $tx_bot.nil?
        log 'ERROR: $tx_bot must be defined before MessageQueue can start.', :red
        exit
      end
    end
end