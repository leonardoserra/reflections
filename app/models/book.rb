class Book < Document
  has_many :pages, as: :pageable, dependent: :destroy

  validates :author, presence: true

  def ordered_pages
    pages.order(:number)
  end
end
