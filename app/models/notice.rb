class Notice < ActiveRecord::Base
  validates :number, presence: true, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 3}
  validates :message, presence: true
  validates :ch_index, presence: true
end