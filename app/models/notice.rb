class Notice < ActiveRecord::Base
  validates :number, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 3}
end