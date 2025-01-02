class NoticesBot
  def initialize
  end

  def monitor
    Thread.new {
      while true
        variable = Variable.where(key: :notices_last_sent_at).first_or_initialize
        variable.value = 2.days.ago if variable.value.blank?
        if Time.now.hour >= 18 && Time.parse(variable.value) < 1.day.ago
          sleep 1
          next
        end
        variable.value = Time.now
        next if !variable.save
        Notice.order(:order).each do |notice|
          $tx_bot.send_text(notice.message, notice.ch_index)
        end
      end
    }
    self
  end
end