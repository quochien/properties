class Lot < ApplicationRecord
  belongs_to :site

  scope :active, -> { where(enabled: true) }
end
