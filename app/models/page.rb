class Page < ApplicationRecord
  validates :pageable_type, uniqueness: { scope: :pageable_id }, if: -> { pageable_type == Reflection.name }
  validates :number, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :pageable, polymorphic: true
end
