FactoryBot.define do
  factory :review do
    user
    haiku
    score { 3 }

    trait :with_comment do
      comment { '素晴らしい句ですね。' }
    end

    trait :with_correction do
      correction_body { 'ふるいけやかわずとびこむみずのおと' }
      correction_reason { '五七五のリズムを整えました。' }
    end
  end
end
