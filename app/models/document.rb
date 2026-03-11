class Document < ApplicationRecord
  belongs_to :user, inverse_of: :documents

  validates :name, presence: true
end
