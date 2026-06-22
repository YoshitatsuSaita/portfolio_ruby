FactoryBot.define do
  factory :kigo_explanation do
    kigo_word { '蛙' }
    season { '春' }
    explanation { '春の季語。水辺に棲む両生類。' }

    trait :none_season do
      kigo_word { 'パソコン' }
      season { 'none' }
      explanation { nil }
    end

    trait :with_canonical do
      kigo_word { '冬月' }
      canonical_word { '冬の月' }
      season { '冬' }
      explanation { '冬の季語。冬の夜空に浮かぶ月。' }
    end

    trait :with_parent do
      kigo_word { '山桜' }
      parent_kigo { '桜' }
      season { '春' }
      explanation { '春の季語。山に咲く桜。' }
    end
  end
end
