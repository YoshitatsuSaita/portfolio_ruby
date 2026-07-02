require 'rails_helper'

RSpec.describe Haiku do
  let(:haiku) { create(:haiku) }

  describe 'バリデーション' do
    context '有効なデータの場合' do
      it '有効であること' do
        expect(haiku).to be_valid
      end
    end

    context 'bodyが空の場合' do
      it '無効であること' do
        haiku.body = ''
        expect(haiku).not_to be_valid
      end
    end

    context 'bodyが5文字未満の場合' do
      it '無効であること' do
        haiku.body = 'あいうえ'
        expect(haiku).not_to be_valid
      end
    end

    context 'bodyが30文字を超える場合' do
      it '無効であること' do
        haiku.body = 'あ' * 31
        expect(haiku).not_to be_valid
      end
    end

    context 'kigoが空の場合' do
      it '無効であること' do
        haiku.kigo = ''
        expect(haiku).not_to be_valid
      end
    end
  end

  describe 'enum' do
    it 'ステータスが正しく定義されていること' do
      expect(described_class.statuses.keys).to eq(
        %w[draft published submitted_to_admin pending_publication]
      )
    end
  end

  describe 'scope' do
    let!(:published_haiku) { create(:haiku) }
    let!(:draft_haiku) { create(:haiku, :draft) }

    describe '.visible' do
      it '公開中の句のみ返すこと' do
        result = described_class.visible
        expect(result).to include(published_haiku)
        expect(result).not_to include(draft_haiku)
      end
    end

    describe '.pending_review' do
      let!(:submitted_haiku) do
        create(:haiku, :submitted)
      end

      it '管理者投稿の句のみ返すこと' do
        result = described_class.pending_review
        expect(result).to include(submitted_haiku)
        expect(result).not_to include(published_haiku)
        expect(result).not_to include(draft_haiku)
      end
    end

    describe '.by_theme' do
      let!(:themed_haiku) do
        create(:haiku, :with_theme)
      end

      it '指定したお題の句を返すこと' do
        result = described_class.by_theme('自然')
        expect(result).to include(themed_haiku)
        expect(result).not_to include(published_haiku)
      end
    end
  end

  describe '.to_text' do
    it 'テキスト文字列を返すこと' do
      haiku = create(:haiku)
      text = described_class.to_text([haiku])
      expect(text).to include(haiku.body)
      expect(text).to include(haiku.kigo)
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーが削除されると句も削除されること' do
      user = haiku.user
      expect { user.destroy }.to change(
        described_class, :count
      ).by(-1)
    end
  end
end
