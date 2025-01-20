if ActiveRecord::Base.connected?

  Elasticsearch::Model.client = Elasticsearch::Client.new(
    url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200',
    log: true
  )
  # config/initializers/elasticsearch.rb
  Rails.application.config.after_initialize do
    begin
      # Create Elasticsearch index for the Message model if it doesn't exist
      unless Message.__elasticsearch__.index_exists?
        Message.__elasticsearch__.create_index!
        Rails.logger.info "Elasticsearch index for Message created successfully."

        # Import all existing messages into Elasticsearch
        Message.import
        Rails.logger.info "Existing messages imported into Elasticsearch index."
      end
    rescue StandardError => e
      Rails.logger.error "Error setting up Elasticsearch: #{e.message}"
    end
  end
else
  Rails.logger.info("Skipping elasticsearch initialization because the database is not connected.")
end