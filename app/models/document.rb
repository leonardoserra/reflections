class Document < ApplicationRecord
  belongs_to :user, inverse_of: :documents
  has_many :pages, as: :pageable, dependent: :destroy

  validates :name, presence: true

  def self.polymorphic_name
    name
  end

  def ordered_pages
    raise NotImplementedError
  end
end
