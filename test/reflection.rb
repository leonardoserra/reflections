class Reflection < Document
  has_one :page, as: :pageable, dependent: :destroy
end
