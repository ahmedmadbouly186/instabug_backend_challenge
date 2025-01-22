FactoryBot.define do
  factory :app do
    name { Faker::App.name }
    token { SecureRandom.hex(16) }
    chat_count { 0 } # Default value as per migration
  end
end
