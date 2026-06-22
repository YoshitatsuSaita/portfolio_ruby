require 'rails_helper'

RSpec.describe KigoExplanation do
  describe 'バリデーション' do
    context '有効なデータの場合' do
      it '有効であること' do
        explanation = build(:kigo_explanation)
        expect(explanation).to be_valid
      end
    end

    context 'kigo_wordが空の場合' do
      it '無効であること' do
        explanation = build(
          :kigo_explanation, kigo_word: ''
        )
        expect(explanation).not_to be_valid
      end
    end

    context 'seasonが空の場合' do
      it '無効であること' do
        explanation = build(
          :kigo_explanation, season: ''
        )
        expect(explanation).not_to be_valid
      end
    end

    context 'kigo_wordが重複する場合' do
      it '無効であること' do
        create(:kigo_explanation)
        duplicate = build(:kigo_explanation)
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe '#none_season?' do
    it '無季の場合trueを返すこと' do
      explanation = build(
        :kigo_explanation, :none_season
      )
      expect(explanation).to be_none_season
    end

    it '季語がある場合falseを返すこと' do
      explanation = build(:kigo_explanation)
      expect(explanation).not_to be_none_season
    end
  end
end
