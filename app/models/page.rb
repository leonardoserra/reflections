class Page < ApplicationRecord
  before_create :check_number

  validates :pageable_type, uniqueness: { scope: :pageable_id }, if: -> { pageable_type == "Reflection" }
  validates :number, presence: true

  belongs_to :pageable, polymorphic: true

  private

  def check_number
    if self.number.negative?
      raise
    end
  end
end
