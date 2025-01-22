require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ChatCreationJob, type: :job do
  let(:app) { create(:app) }
  let(:chat_number) { 1 }

  before do
    Sidekiq::Testing.inline!  # To run jobs immediately during tests
  end

  after do
    Sidekiq::Testing.fake!  # Restore normal job processing behavior after tests
  end

  it 'creates a chat and increments the chat_count of the app' do
    expect {
      ChatCreationJob.new.perform(app.token, chat_number)
    }.to change { app.reload.chat_count }.by(1)

    # Check if the chat was created successfully
    chat = app.chats.find_by(chat_number: chat_number)
    expect(chat).not_to be_nil
    expect(chat.chat_number).to eq(chat_number)
  end

  it 'logs an error if the app is not found' do
    allow(Rails.logger).to receive(:error)

    expect {
      ChatCreationJob.new.perform('invalid_token', chat_number)
    }.to change { app.reload.chat_count }.by(0)  # No chat created
    expect(Rails.logger).to have_received(:error).with(/App not found/)
  end

  it 'logs an error if chat creation fails' do
    allow(Rails.logger).to receive(:error)

    # Simulate failure in chat creation (e.g., invalid chat_number)
    expect {
      ChatCreationJob.new.perform(app.token, nil)
    }.to change { app.reload.chat_count }.by(0)  # No chat created
    expect(Rails.logger).to have_received(:error).with(/Failed to create chat/)
  end
end
