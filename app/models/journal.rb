class Journal < Document
  has_many :pages, as: :pageable, dependent: :destroy
end
