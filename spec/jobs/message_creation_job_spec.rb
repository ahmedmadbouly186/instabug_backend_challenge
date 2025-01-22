require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MessageCreationJob, type: :job do
  let(:app) { create(:app) }
  let(:chat) { create(:chat, app: app) }
  let(:message_number) { 1 }
  let(:body) { "Hello, world!" }

  before do
    Sidekiq::Testing.inline!  # To run jobs immediately during tests
  end

  after do
    Sidekiq::Testing.fake!  # Restore normal job processing behavior after tests
  end

  it 'creates a message and increments the message_count of the chat' do
    expect {
      MessageCreationJob.new.perform(app.token, chat.chat_number, message_number, body)
    }.to change { chat.reload.messages_count }.by(1)

    # Check if the message was created successfully
    message = chat.messages.find_by(message_number: message_number)
    expect(message).not_to be_nil
    expect(message.body).to eq(body)
  end

  it 'logs an error if the app is not found' do
    allow(Rails.logger).to receive(:error)

    expect {
      MessageCreationJob.new.perform('invalid_token', chat.chat_number, message_number, body)
    }.to change { chat.reload.messages_count }.by(0)  # No message created
    expect(Rails.logger).to have_received(:error).with(/App not found/)
  end

  it 'logs an error if the chat is not found' do
    allow(Rails.logger).to receive(:error)

    # Use a non-existent chat number
    expect {
      MessageCreationJob.new.perform(app.token, 999, message_number, body)
    }.to change { chat.reload.messages_count }.by(0)  # No message created
    expect(Rails.logger).to have_received(:error).with(/Chat not found/)
  end

  it 'logs an error if message creation fails' do
    allow(Rails.logger).to receive(:error)

    # Simulate a failure during message creation (e.g., by passing invalid data)
    expect {
      MessageCreationJob.new.perform(app.token, chat.chat_number, message_number, nil)
    }.to change { chat.reload.messages_count }.by(0)  # No message created
    expect(Rails.logger).to have_received(:error).with(/Failed to create message/)
  end
end
