FactoryBot.define do
  factory :chat do
    association :app  # Automatically creates an App object for the Chat
    messages_count { 0 } # Default value
    chat_number { Faker::Number.unique.number(digits: 4) } # Random unique chat number
  end
end
