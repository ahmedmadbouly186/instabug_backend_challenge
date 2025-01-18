class CreateApps < ActiveRecord::Migration[8.0]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :token
      t.integer :chat_count, default: 0

      t.timestamps
    end

    add_index :apps, :token, unique: true  # Ensure unique index on token
   end
end
