class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :body
      t.references :chat, null: false, foreign_key: true
      t.integer :message_number

      t.timestamps
    end
  end
end
