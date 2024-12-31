class Message < ActiveRecord::Base
  validates :ch_index, presence: true
  validates :message, presence: true
  validates :node_id, presence: true
  belongs_to :node
end