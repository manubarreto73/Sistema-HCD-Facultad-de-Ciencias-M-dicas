class Destination < ApplicationRecord
  validates :name, uniqueness: true
end
