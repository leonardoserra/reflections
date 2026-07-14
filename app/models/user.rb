class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :documents, inverse_of: :user,  dependent: :destroy

  has_many :books
  has_many :journals
  has_many :reflections

  validates :name, presence: true
  validates :email_address, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
