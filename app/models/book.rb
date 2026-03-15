class Book < Document
  has_many :pages, as: :pageable, dependent: :destroy
end
