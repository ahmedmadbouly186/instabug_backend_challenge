class App < ApplicationRecord
  has_many :chats, dependent: :destroy
end
