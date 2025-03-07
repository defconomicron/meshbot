class RxBot
  attr_accessor :name, :host

  def initialize(options={})
    @name = options[:name]
    log 'INITIALIZING...', :green
    @host = options[:host]
    log 'DONE!', :green
  end

  def monitor
    $rx_bot.log 'IGNORING RESPONSES FOR 30 SECONDS...', :yellow
    deaf = true
    Thread.new {sleep 30;deaf = false;$rx_bot.log 'NO LONGER IGNORING RESPONSES!', :yellow}
    Thread.new {
      begin
        ignore = []
        MeshtasticCli.new(host: @host, name: @name).responses do |response|
          number = response['num'].presence || response['from']
          next if number.blank?
          node = Node.where(number: number).first_or_initialize
          node.updated_at = Time.now
          node.save
          case response['portnum']
            when 'TEXT_MESSAGE_APP'
              log "[#{node.name}]: #{response}", :blue
              ch_index = channel = response['channel'] rescue nil
              payload = response['payload'] rescue nil
              ch_index ||= 0
              payload = "#{payload}".strip
              Message.create(ch_index: ch_index, node_id: node.id, message: payload)
              params_arr = [payload.split(' ')[1..-1]].compact.flatten
              params_str = params_arr.join(' ')
              if ignore.include?(node.number) || node.ignore? || node.short_name == $tx_bot.name || deaf
                log "#{node.number} IS CURRENTLY IGNORED!", :red
                next
              end
              $TEXT_MESSAGE_HANDLERS.each {|handler|
                texts = [handler.call(payload: payload, params_arr: params_arr, params_str: params_str, ch_index: ch_index, node: node)].flatten.compact.select(&:present?)
                texts.each {|text| $tx_bot.send_text(text, ch_index)}
                if texts.present?
                  log "IGNORING #{node.number} FOR 10 SECONDS...", :red
                  ignore << node.number
                  Thread.new {sleep 10;ignore -= [node.number];log "#{node.number} NO LONGER IGNORED!", :red}
                  break
                end
              }
            when 'POSITION_APP'
              log "[#{node.name}]: #{response}", :blue
              node.position_snapshot = response.to_json
              node.save
            when 'TELEMETRY_APP'
              log "[#{node.name}]: #{response}", :blue
              node.telemetry_snapshot = response.to_json
              node.save
            when 'NODEINFO_APP'
              log "[#{node.name}]: #{response}", :blue
              node.nodeinfo_snapshot = response.to_json
              node.save
            else
              log "[#{node.name}]: #{response}", :black
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
