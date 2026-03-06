class Page < ApplicationRecord
  belongs_to :pageable, polymorphic: true
end
