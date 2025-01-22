FactoryBot.define do
  factory :message do
    association :chat  # Automatically creates a Chat object for the Message
    body { Faker::Lorem.sentence } # Random sentence as message body
    message_number { Faker::Number.unique.number(digits: 6) } # Random unique message number
  end
end
