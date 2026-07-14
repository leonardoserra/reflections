class Journal < Document
  def ordered_pages
    pages.order(page_date: :desc, number: :asc)
  end
end
