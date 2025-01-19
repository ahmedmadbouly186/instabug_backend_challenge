class Chat < ApplicationRecord
  belongs_to :app
  has_many :messages, dependent: :destroy
  validates :chat_number, uniqueness: { scope: :app_id, message: "must be unique within the same app" }
  # before_create :set_chat_number_and_messages_count

  # private

  # def set_chat_number_and_messages_count
  #   # Ensure chat_number is set automatically before creating a chat
  #   max_chat_number = app.chats.maximum(:chat_number) || 0
  #   self.chat_number = max_chat_number + 1

  #   # Set messages_count to 0 by default
  #   self.messages_count ||= 0
  # end
end
