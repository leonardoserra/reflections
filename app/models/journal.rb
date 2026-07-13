class Journal < Document
  has_many :pages, as: :pageable, dependent: :destroy

  def ordered_pages
    pages.order(page_date: :desc, number: :asc)
  end
end
