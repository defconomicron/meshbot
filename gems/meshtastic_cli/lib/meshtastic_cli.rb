require 'json/repair'
require 'pty'

class MeshtasticCli
  def initialize(options)
    @host = options[:host]
    @name = options[:name]
  end

  def packets(&block)
    PTY.spawn("meshtastic --host #{@host} --listen") do |stdout, stdin, pid|
      packet = nil
      stdout.each do |line|
        # $log_it.log "[#{@name}] RAW: #{line.strip}"
        str = line.strip.force_encoding('UTF-8')
        if str =~ /DEBUG/
          packet = str << "\n"
        elsif packet.present?
          packet << str << "\n"
        end
        if packet.present? && str =~ /\}/
          packet = case packet
            when /packet/ then packet.split('packet')[1].strip rescue ''
            when /node_info/ then packet.split('node_info')[1].strip rescue ''
            else packet
          end
          packet = JSON.parse(JSON.repair(packet)) rescue nil
          yield packet if packet.present?
          packet = nil
        end
      end
    end
  rescue Exception => e
    $log_it.log "[#{@name}] EXCEPTION: #{e}: #{e.backtrace}", :red
  end
end
