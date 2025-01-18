class Message < ApplicationRecord
  belongs_to :chat

  validates :message_number, uniqueness: { scope: :chat_id, message: "must be unique within the same chat" }

  before_create :set_message_number

  private

  def set_message_number
    max_message_number = chat.messages.maximum(:message_number) || 0
    self.message_number = max_message_number + 1
  end
end
