require 'rails_helper'

RSpec.describe App, type: :model do
  it 'is valid with valid attributes' do
    app = build(:app)
    expect(app).to be_valid
  end

  it 'is invalid without a name' do
    app = build(:app, name: nil)
    expect(app).not_to be_valid
  end

  it 'is invalid with a duplicate token' do
    create(:app, token: 'unique_token')  # Create the first app with a token
    app = build(:app, token: 'unique_token')  # Try to build another app with the same token
    expect(app).not_to be_valid  # It should be invalid due to the duplicate token
    expect(app.errors[:token]).to include('has already been taken')  # Ensure the correct error message is present
  end
end
