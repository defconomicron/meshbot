class Node < ActiveRecord::Base
  before_save :set_short_name
  before_save :set_long_name

  has_one :trivia_profile

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
end