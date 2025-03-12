class RxBot
  attr_accessor :name, :host, :deaf, :ignored_node_numbers

  def initialize(options={})
    @name = options[:name]
    log 'INITIALIZING...', :green
    @host = options[:host]
    @deaf = true
    @ignored_node_numbers = []
    log 'DONE!', :green
  end

  def monitor
    temporarily_ignore_text_messages
    Thread.new {
      responses do |response|
        begin
          number = response['num'].presence || response['from']
          next if number.blank?
          node = Node.where(number: number).first_or_initialize
          node.updated_at = Time.now
          node.save
          case response['portnum']
            when 'TEXT_MESSAGE_APP'
              log "[#{node.name}]: #{response}", :blue
              ch_index = extract_ch_index(response)
              payload = extract_payload(response)
              Message.create(node_id: node.id, ch_index: ch_index, message: payload)
              params_arr = payload_to_params_arr(payload)
              params_str = params_arr_to_params_str(params_arr)
              if node_ignored?(node)
                log "#{node.name} IS CURRENTLY IGNORED!", :red
                next
              end
              options = {
                node:       node,
                ch_index:   ch_index,
                payload:    payload,
                params_arr: params_arr,
                params_str: params_str
              }
              $TEXT_MESSAGE_HANDLERS.each {|handler|
                texts = [handler.call(options)].flatten.compact.select(&:present?)
                texts.each {|text| $tx_bot.send_text(text, ch_index)}
                if texts.present?
                  temporarily_ignore_node_number(node.number)
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
        rescue Exception => e
          log "EXCEPTION: #{e}: #{e.backtrace}", :red
          log "Whew! I'm going to sleep... Be back in a second.", :yellow
          sleep 1
          log "Okay, I'm awake again and listening for new responses!", :yellow
          retry
        end
      end
    }
    self
  end

  def log(text, color = nil)
    $log_it.log "[#{@name}] #{text}", color
  end

  private

    def payload_to_params_arr(payload)
      [payload.split(' ')[1..-1]].compact.flatten
    end

    def params_arr_to_params_str(params_arr)
      params_arr.join(' ')
    end

    def extract_payload(response)
      "#{(response['payload'] rescue nil)}".strip
    end

    def extract_ch_index(response)
      (response['channel'] rescue nil) || 0
    end

    def responses
      MeshtasticCli.new(host: @host, name: @name).responses {|response| yield response}
    end

    def node_ignored?(node)
      @ignored_node_numbers.include?(node.number) || node.ignore? || node.short_name == $tx_bot.name || @deaf
    end

    def temporarily_ignore_node_number(number)
      log "IGNORING #{number} FOR 10 SECONDS...", :red
      @ignored_node_numbers << number
      Thread.new {sleep 10;@ignored_node_numbers -= [number];log("#{number} NO LONGER IGNORED!", :red)}
    end

    def temporarily_ignore_text_messages
      log 'IGNORING TEXT MESSAGES FOR 30 SECONDS...', :yellow
      @deaf = true
      Thread.new {sleep 30;@deaf = false;log('NO LONGER IGNORING TEXT MESSAGES!', :yellow)}
    end
end
