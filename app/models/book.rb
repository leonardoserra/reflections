class Book < Document
  validates :author, presence: true

  def ordered_pages
    pages.order(:number)
  end
end
