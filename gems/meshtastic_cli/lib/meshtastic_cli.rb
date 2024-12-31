require 'json/repair'
require 'pty'

class MeshtasticCli
  def initialize(options)
    @host = options[:host]
  end

  def reboot
    $log_it.log "REBOOTING #{@host}!", :red
    `#{$meshtastic_path} --host #{@host} --reboot`
  end

  def responses(&block)
    PTY.spawn("#{$meshtastic_path} --host #{@host} --listen") do |stdout, stdin, pid|
      response = nil
      stdout.each do |line|
        $log_it.log "RAW: #{line.strip}"
        str = line.strip.force_encoding('UTF-8')
        if str =~ /DEBUG/
          response = str << "\n"
        elsif response.present?
          response << str << "\n"
          if str.blank?
            response = case response
              when /packet/ then response.split('packet')[1].strip rescue ''
              when /node_info/ then response.split('node_info')[1].strip rescue ''
              else response
            end
            response = JSON.parse(JSON.repair(response)) rescue nil
            yield response if response.present?
            response = nil
          end
        end
      end
    end
  end
end
