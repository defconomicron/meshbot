class Node < ActiveRecord::Base
  has_many :messages
  has_one :trivia_profile

  validates :number, presence: true

  before_save :set_short_name
  before_save :set_long_name

  def set_short_name
    str = JSON.parse(user_snapshot)['short_name'] rescue nil
    self.short_name = str if str.present?
  end

  def set_long_name
    str = JSON.parse(user_snapshot)['long_name'] rescue nil
    self.long_name = str if str.present?
  end

  def ignore?
    ignored_at.present?
  end

  def latitude_i
    JSON.parse(position_snapshot)['latitude_i'] rescue nil
  end

  def latitude
    latitude_i / 10000000.0
  end

  def longitude_i
    JSON.parse(position_snapshot)['longitude_i'] rescue nil
  end

  def longitude
    longitude_i / 10000000.0
  end
end