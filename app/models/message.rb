class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :chat
  validates :message_number, presence: true
  validates :message_number, uniqueness: { scope: :chat_id, message: "must be unique within the same chat" }
  validates :body, presence: true

  settings do
    mappings dynamic: false do
      indexes :chat_id, type: :keyword  # Ensuring chat_id is indexed for filtering
      indexes :body, type: :text, analyzer: 'english'  # Full-text search on body
    end
  end

  def self.search(query, chat_id)
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: [
              { match: { body: query } },     # Search within the body of the message
            ],
            filter: [
              { term: { chat_id: chat_id.to_i } }  # Filter by chat_id
            ]
          }
        }
      }
    )
  end
end
