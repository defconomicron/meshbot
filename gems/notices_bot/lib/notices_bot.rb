class NoticesBot
  def initialize
  end

  def monitor
    Thread.new {
      while true
        variable = Variable.where(key: :notices_last_sent_at).first_or_initialize
        variable.value = 2.days.ago if variable.value.blank?
        if Time.now.hour < 18 || 1.day.ago < Time.parse(variable.value)
          sleep 1
          next
        end
        variable.value = Time.now
        next if !variable.save
        Notice.order(:order).each {|notice|
          $message_transmitter.transmit(ch_index: notice.ch_index, message: notice.message)
        }
      end
    }
    self
  end
end