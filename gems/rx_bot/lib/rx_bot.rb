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
          next if !response.is_a?(Hash)
          next if response['num'].blank? && response['from'].blank?
          node = Node.where(number: response['num'].presence || response['from']).first_or_initialize
          next if node.ignore? || node.short_name == $tx_bot.name
          node.updated_at = Time.now
          node.save
          log "RX: #{response}", :blue
          case response['portnum']
            when 'TEXT_MESSAGE_APP'
              ch_index = channel = response['channel'] rescue nil
              payload = response['payload'] rescue nil
              ch_index ||= 0
              payload = "#{payload}".strip
              Message.create(ch_index: ch_index, node_id: node.id, message: payload)
              params_arr = [payload.split(' ')[1..-1]].compact.flatten
              params_str = params_arr.join(' ')
              $TEXT_MESSAGE_HANDLERS.each {|handler|
                [handler.call(payload: payload, params_arr: params_arr, params_str: params_str, ch_index: ch_index, node: node)].flatten.compact.each do |text|
                  $tx_bot.send_text(text, ch_index) if text.present?
                end
              }
            when 'POSITION_APP'
              node.position_snapshot = response.to_json
              node.save
            when 'TELEMETRY_APP'
              node.telemetry_snapshot = response.to_json
              node.save
            when 'NODEINFO_APP'
              node.nodeinfo_snapshot = response.to_json
              node.save
          end
        end
      rescue Exception => e
        log "EXCEPTION: #{e}: #{e.backtrace}", :red
        log "Whew! I'm going to sleep... Be back in a minute.", :yellow
        sleep 1
        log "Okay, I'm awake again and listening for new responses!", :yellow
        retry
      end
    }
    self
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end
end
