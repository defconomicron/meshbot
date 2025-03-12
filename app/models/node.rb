class Node < ActiveRecord::Base
  has_many :messages
  has_one :trivia_profile

  validates :number, presence: true

  before_save :set_short_name
  before_save :set_long_name

  def set_short_name
    str = (JSON.parse(user_snapshot)['short_name'] rescue nil).presence ||
          (JSON.parse(nodeinfo_snapshot)['short_name'] rescue nil)
    self.short_name = str if str.present?
  end

  def set_long_name
    str = (JSON.parse(user_snapshot)['long_name'] rescue nil).presence ||
          (JSON.parse(nodeinfo_snapshot)['long_name'] rescue nil)
    self.long_name = str if str.present?
  end

  def ignore?
    ignored_at.present?
  end

  def latitude
    JSON.parse(position_snapshot)['latitude'] rescue nil
  end

  def longitude
    JSON.parse(position_snapshot)['longitude'] rescue nil
  end

  def name
    [short_name, long_name].select(&:present?).join(': ').presence || number.presence || 'UNKNOWN'
  end
end