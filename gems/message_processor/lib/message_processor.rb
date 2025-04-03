class MessageProcessor
  def initialize
    @ignored_node_numbers = []
  end

  def process
    Thread.new {
      @time = 0
      $message_receiver.try(:receive) do |message|
        number = message['num'].presence || message['from']
        next if number.blank?
        node = Node.where(number: number).first_or_initialize
        node.updated_at = Time.now
        node.save
        case message['portnum']
          when 'TEXT_MESSAGE_APP'
            if @time < message['time'].to_i
              log "[#{node.name}]: #{message}", :blue
              ch_index = extract_ch_index(message)
              payload = extract_payload(message)
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
                texts.each {|text| $message_transmitter.transmit(ch_index: ch_index, message: text)}
                if texts.present?
                  temporarily_ignore_node_number(node.number)
                  break
                end
              }
              @time = message['time'].to_i
            end
          when 'POSITION_APP'
            # log "[#{node.name}]: #{message}", :blue
            node.position_snapshot = message.to_json
            node.save
          when 'TELEMETRY_APP'
            # log "[#{node.name}]: #{message}", :blue
            node.telemetry_snapshot = message.to_json
            node.save
          when 'NODEINFO_APP'
            # log "[#{node.name}]: #{message}", :blue
            node.nodeinfo_snapshot = message.to_json
            node.save
          else
            # log "[#{node.name}]: #{message}", :black
        end
      end
    }
    self
  end

  private

    def log(text, color = nil)
      $log_it.log "MessageProcessor: #{text}", color
    end

    def payload_to_params_arr(payload)
      [payload.split(' ')[1..-1]].compact.flatten
    end

    def params_arr_to_params_str(params_arr)
      params_arr.join(' ')
    end

    def extract_payload(message)
      "#{(message['payload'] rescue nil)}".strip
    end

    def extract_ch_index(message)
      (message['channel'] rescue nil) || 0
    end

    def node_ignored?(node)
      @ignored_node_numbers.include?(node.number) || node.ignore? || node.short_name == $short_name || @deaf
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