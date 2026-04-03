class Document < ApplicationRecord
  belongs_to :user, inverse_of: :documents

  validates :name, presence: true

  def current_page
    Page.find_by(number: bookmark, pageable_id: id)
  end
end
