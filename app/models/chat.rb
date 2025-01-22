class Chat < ApplicationRecord
  belongs_to :app
  has_many :messages, dependent: :destroy
  validates :chat_number, presence: true
  validates :chat_number, uniqueness: { scope: :app_id, message: "must be unique within the same app" }
end
