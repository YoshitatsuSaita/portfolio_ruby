FactoryBot.define do
  factory :topic_assignment do
    association :sender, factory: %i[user admin]
    user
    theme { '夏の思い出' }
    deadline { 1.week.from_now.to_date }

    trait :past_deadline do
      deadline { 1.day.ago.to_date }
    end

    trait :no_deadline do
      deadline { nil }
    end

    trait :with_message do
      message { '自由に詠んでください。' }
    end
  end
end
