class Variable < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true
end