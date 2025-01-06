class RxBot
  attr_accessor :name, :host

  def initialize(options={})
    @name = options[:name]
    log 'INITIALIZING...', :green
    @host = options[:host]
    log 'DONE!', :green
  end

  def monitor
    Thread.new {
      begin
        MeshtasticCli.new(host: @host, name: @name).responses do |response|
          packet = response
          next if !packet.is_a?(Hash)
          node = Node.where(number: packet['num'].presence || packet['from']).first_or_initialize
          next if node.ignore? || node.short_name == $tx_bot.name
          if packet.keys.include?('user')
            nodeinfo_snapshot = packet.to_json
            log "RX: #{nodeinfo_snapshot}", :blue
            node.nodeinfo_snapshot = nodeinfo_snapshot
            user_snapshot = packet['user'].to_json
            log "RX: #{user_snapshot}", :blue
            node.user_snapshot = user_snapshot
          end
          if packet.keys.include?('position')
            position_snapshot = packet['position'].to_json
            log "RX: #{position_snapshot}", :blue
            node.position_snapshot = position_snapshot
          end
          if packet.keys.include?('device_metrics')
            device_metrics_snapshot = packet['device_metrics'].to_json
            log "RX: #{device_metrics_snapshot}", :blue
            node.device_metrics_snapshot = device_metrics_snapshot
          end
          node.updated_at = Time.now
          node.save
          if packet.keys.include?('decoded')
            ch_index = channel = packet['channel'] rescue nil
            payload = packet['decoded']['payload'] rescue nil
            ch_index ||= 0
            log "RX: #{packet}", :blue
            payload = "#{payload}".strip
            Message.create(ch_index: ch_index, node_id: node.id, message: payload)
            params_arr = [payload.split(' ')[1..-1]].compact.flatten
            params_str = params_arr.join(' ')
            $TEXT_MESSAGE_HANDLERS.each {|handler|
              [handler.call(payload: payload, params_arr: params_arr, params_str: params_str, ch_index: ch_index, node: node)].flatten.compact.each do |text|
                $tx_bot.send_text(text, ch_index) if text.present?
              end
            }
          end
        end
      rescue Exception => e
        log "EXCEPTION: #{e}: #{e.backtrace}", :red
        log "Whew! I'm going to sleep... Be back in a minute.", :yellow
        sleep 1
        log "Okay, I'm awake again and listening for new packets!", :yellow
        retry
      end
    }
    self
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end
end
