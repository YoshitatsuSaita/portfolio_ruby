require 'rails_helper'

RSpec.describe TopicAssignment do
  describe 'バリデーション' do
    context '有効なデータの場合' do
      it '有効であること' do
        ta = build(:topic_assignment)
        expect(ta).to be_valid
      end
    end

    context 'themeが空の場合' do
      it '無効であること' do
        ta = build(:topic_assignment, theme: '')
        expect(ta).not_to be_valid
      end
    end

    context 'deadlineが今日の場合' do
      it '有効であること' do
        ta = build(:topic_assignment, deadline: Date.current)
        expect(ta).to be_valid
      end
    end

    context 'deadlineが未来の場合' do
      it '有効であること' do
        ta = build(:topic_assignment, deadline: 1.week.from_now.to_date)
        expect(ta).to be_valid
      end
    end

    context 'deadlineが過去の場合' do
      it '無効であること' do
        ta = build(:topic_assignment, deadline: 1.day.ago.to_date)
        expect(ta).not_to be_valid
        expect(ta.errors[:deadline]).to include('は今日以降の日付を指定してください')
      end
    end

    context 'deadlineが空の場合' do
      it '有効であること' do
        ta = build(:topic_assignment, :no_deadline)
        expect(ta).to be_valid
      end
    end
  end

  describe 'scope' do
    describe '.unread' do
      it '未読のお題のみ返すこと' do
        unread = create(:topic_assignment, read: false)
        create(:topic_assignment, read: true)
        expect(described_class.unread).to eq([unread])
      end
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーが削除されるとお題も削除されること' do
      ta = create(:topic_assignment)
      user = ta.user
      expect { user.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
