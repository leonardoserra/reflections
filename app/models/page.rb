class Page < ApplicationRecord
  MAX_BODY_LENGTH = 1500

  validates :pageable_type, uniqueness: { scope: :pageable_id }, if: -> { pageable_type == Reflection.name }
  validates :number, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :body, length: { maximum: MAX_BODY_LENGTH }

  belongs_to :pageable, polymorphic: true

  def journal_page?
    pageable_type == Journal.name
  end
end
