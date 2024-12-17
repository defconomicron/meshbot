class Node < ActiveRecord::Base
  before_save :set_short_name
  before_save :set_long_name

  has_one :trivia_profile

  def set_long_name
    self.long_name = JSON.parse(nodeinfo_snapshot)['decoded']['payload']['long_name'] rescue nil
  end

  def set_short_name
    self.short_name = JSON.parse(nodeinfo_snapshot)['decoded']['payload']['short_name'] rescue nil
  end

  def ignore?
    ignored_at.present?
  end
end