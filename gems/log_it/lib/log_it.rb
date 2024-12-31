class LogIt
  # COLORS = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, :default, :light_black, :light_red, :light_green, :light_yellow, :light_blue, :light_magenta, :light_cyan, :light_white, :grey, :gray]

  def initialize
  end

  def log(str, color = :grey)
    _str = "[#{Time.now.human}] #{str.presence.try(:strip) || '-'}"
    File.write("#{File.dirname(__FILE__)}/../../../log/log.txt", "#{_str}\n", mode: 'a') rescue nil
    puts _str.colorize(color.presence || :grey)
  end
end