FactoryBot.define do
  factory :haiku do
    user
    body { 'はるのうみひねもすのたり' }
    kigo { '春の海' }
    status { :published }

    trait :draft do
      status { :draft }
    end

    trait :submitted do
      status { :submitted_to_admin }
    end

    trait :with_theme do
      theme { '自然' }
    end
  end
end
