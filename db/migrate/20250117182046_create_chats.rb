class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.references :app, null: false, foreign_key: true
      t.integer :messages_count, default: 0
      t.integer :chat_number

      t.timestamps
    end
  end
end
