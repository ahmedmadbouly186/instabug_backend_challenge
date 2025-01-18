class AddIndexesToChatsAndMessages < ActiveRecord::Migration[8.0]
  def change
    # Add indexes to chats table
    add_index :chats, [:app_id, :chat_number], unique: true

    # Add indexes to messages table
    add_index :messages, [:chat_id, :message_number], unique: true
  end
end
