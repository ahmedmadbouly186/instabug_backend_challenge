require 'rails_helper'
require 'spec_helper'


RSpec.describe Chat, type: :model do
  it 'belongs to an app' do
    should belong_to(:app)
  end

  it 'is invalid without a chat_number' do
    chat = build(:chat, chat_number: nil)
    expect(chat).not_to be_valid
  end
  
  it 'is invalid without an app_id' do
    chat = build(:chat, app_id: nil)
    expect(chat).not_to be_valid
  end

  it 'is valid with valid attributes' do
    chat = build(:chat)
    expect(chat).to be_valid
  end

  it 'has a unique chat_number for the same app' do
    app = create(:app)
    create(:chat, app: app, chat_number: 1)
    chat = build(:chat, app: app, chat_number: 1)
    expect(chat).not_to be_valid
  end

  it 'has an initial message_count of 0' do
    chat = build(:chat)
    expect(chat.messages_count).to eq(0)
  end

end

