require 'rails_helper'

RSpec.describe Review do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:haiku) { create(:haiku, user: other_user) }

  describe 'バリデーション' do
    context '有効なデータの場合' do
      it '有効であること' do
        review = build(:review, user: user, haiku: haiku)
        expect(review).to be_valid
      end
    end

    context 'scoreが空の場合' do
      it '無効であること' do
        review = build(
          :review, user: user, haiku: haiku, score: nil
        )
        expect(review).not_to be_valid
      end
    end

    context 'scoreが範囲外の場合' do
      it '0は無効であること' do
        review = build(
          :review, user: user, haiku: haiku, score: 0
        )
        expect(review).not_to be_valid
      end

      it '6は無効であること' do
        review = build(
          :review, user: user, haiku: haiku, score: 6
        )
        expect(review).not_to be_valid
      end
    end

    context '自分の俳句に評価する場合' do
      it '無効であること' do
        review = build(
          :review, user: other_user, haiku: haiku
        )
        expect(review).not_to be_valid
        expect(
          review.errors[:base]
        ).to include('自分の俳句には評価できません。')
      end
    end

    context '同じ句に2回評価する場合' do
      it '無効であること' do
        create(:review, user: user, haiku: haiku)
        duplicate = build(
          :review, user: user, haiku: haiku
        )
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe 'コールバック' do
    context '管理者が管理者投稿の句を評価した場合' do
      let(:admin) { create(:user, :admin) }
      let(:submitted_haiku) do
        create(:haiku, :submitted, user: user)
      end

      it '句が公開待ちになること' do
        create(
          :review, user: admin, haiku: submitted_haiku
        )
        expect(submitted_haiku.reload).to be_pending_publication
      end
    end

    context '一般ユーザーが公開句を評価した場合' do
      it 'ステータスが変わらないこと' do
        create(:review, user: user, haiku: haiku)
        expect(haiku.reload).to be_published
      end
    end
  end

  describe 'アソシエーション' do
    it '俳句が削除されると評価も削除されること' do
      create(:review, user: user, haiku: haiku)
      expect { haiku.destroy }.to change(
        described_class, :count
      ).by(-1)
    end

    it 'ユーザーが削除されると評価も削除されること' do
      create(:review, user: user, haiku: haiku)
      expect { user.destroy }.to change(
        described_class, :count
      ).by(-1)
    end
  end
end
