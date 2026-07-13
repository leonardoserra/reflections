class Reflection < Document
  has_one :page, as: :pageable, dependent: :destroy

  def ordered_pages
    Page.where(id: page&.id)
  end
end
