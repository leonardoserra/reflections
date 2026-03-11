class Page < ApplicationRecord
  belongs_to :pageable, polymorphic: true

  validates :pageable_type, uniqueness: { scope: :pageable_id }, if: -> { pageable_type == "Reflection" }
  validates :number, presence: true
end
