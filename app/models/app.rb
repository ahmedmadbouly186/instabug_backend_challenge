class App < ApplicationRecord
  has_many :chats, dependent: :destroy
  validates :name, presence: true
  validates :token, presence: true
  validates :token, presence: true, uniqueness: { case_sensitive: false }
end
