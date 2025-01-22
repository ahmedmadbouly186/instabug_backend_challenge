require 'rails_helper'

RSpec.describe Message, type: :model do
  it 'belongs to a chat' do
    should belong_to(:chat)
  end

  it 'has a unique message_number within a chat' do
    chat = create(:chat)
    create(:message, chat: chat, message_number: 1)
    message = build(:message, chat: chat, message_number: 1)
    expect(message).not_to be_valid
  end

  it 'is invalid without a body' do
    message = build(:message, body: nil)
    expect(message).not_to be_valid
  end

  it 'is invalid without a message_number' do
    message = build(:message, message_number: nil)
    expect(message).not_to be_valid
  end

  it 'is invalid with a duplicate message_number within a chat' do
    chat = create(:chat)
    create(:message, chat: chat, message_number: 1)
    message = build(:message, chat: chat, message_number: 1)
    expect(message).not_to be_valid
  end
  
  it 'is valid with a body' do
    message = build(:message, body: 'Test message')
    expect(message).to be_valid
  end

  it 'is invalid without a chat_id' do
    message = build(:message, chat_id: nil)
    expect(message).not_to be_valid
  end
end
  