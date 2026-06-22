require 'rails_helper'

RSpec.describe 'Haikus' do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }
  let(:haiku) { create(:haiku, user: user) }

  def log_in_as(login_user)
    post login_path, params: {
      session: {
        email: login_user.email,
        password: 'password',
        remember_me: '0'
      }
    }
  end

  describe 'GET /haikus' do
    it '俳句一覧が表示されること' do
      log_in_as(user)
      create(:haiku)
      get haikus_path
      expect(response).to have_http_status(:ok)
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        get haikus_path
        expect(response).to redirect_to(login_url)
      end
    end

    context 'お題フィルタの場合' do
      it 'フィルタされた結果を返すこと' do
        log_in_as(user)
        create(:haiku, :with_theme)
        get haikus_path, params: { theme: '自然' }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /haikus/:id' do
    it '俳句詳細が表示されること' do
      log_in_as(user)
      get haiku_path(haiku)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /haikus/new' do
    it '投稿フォームが表示されること' do
      log_in_as(user)
      get new_haiku_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /haikus' do
    context '有効なパラメータの場合' do
      it '俳句が作成されること' do
        log_in_as(user)
        expect do
          post haikus_path, params: {
            haiku: {
              body: 'ふるいけやかわずとびこむみず',
              kigo: '蛙',
              status: 'published'
            }
          }
        end.to change(Haiku, :count).by(1)
      end
    end

    context '無効なパラメータの場合' do
      it '俳句が作成されないこと' do
        log_in_as(user)
        expect do
          post haikus_path, params: {
            haiku: {
              body: '',
              kigo: '',
              status: 'published'
            }
          }
        end.not_to change(Haiku, :count)
      end
    end
  end

  describe 'PATCH /haikus/:id' do
    context '本人の場合' do
      it '俳句が更新されること' do
        log_in_as(user)
        patch haiku_path(haiku), params: {
          haiku: { body: 'あたらしいはいくをかいたよ' }
        }
        expect(haiku.reload.body).to eq(
          'あたらしいはいくをかいたよ'
        )
      end
    end

    context '他人の場合' do
      it 'リダイレクトされること' do
        log_in_as(other_user)
        patch haiku_path(haiku), params: {
          haiku: { body: 'かってにへんこう' }
        }
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'DELETE /haikus/:id' do
    context '本人の場合' do
      it '俳句が削除されること' do
        log_in_as(user)
        haiku
        expect do
          delete haiku_path(haiku)
        end.to change(Haiku, :count).by(-1)
      end
    end

    context '他人の場合' do
      it 'リダイレクトされること' do
        log_in_as(other_user)
        delete haiku_path(haiku)
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET /haikus/:id（アクセス制御）' do
    context '管理者投稿の句の場合' do
      let(:submitted) do
        create(:haiku, :submitted, user: user)
      end

      it '投稿者本人は閲覧できること' do
        log_in_as(user)
        get haiku_path(submitted)
        expect(response).to have_http_status(:ok)
      end

      it '管理者は閲覧できること' do
        log_in_as(admin)
        get haiku_path(submitted)
        expect(response).to have_http_status(:ok)
      end

      it '他の一般ユーザーは閲覧できないこと' do
        log_in_as(other_user)
        get haiku_path(submitted)
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET /haikus/mine' do
    it '自分の俳句一覧が表示されること' do
      log_in_as(user)
      create(:haiku, user: user)
      create(:haiku, :draft, user: user)
      get mine_haikus_path
      expect(response).to have_http_status(:ok)
    end

    it 'CSV形式でエクスポートできること' do
      log_in_as(user)
      create(:haiku, user: user)
      get mine_haikus_path(format: :csv)
      expect(response).to have_http_status(:ok)
      expect(
        response.content_type
      ).to include('text/csv')
    end

    it 'テキスト形式でエクスポートできること' do
      log_in_as(user)
      create(:haiku, user: user)
      get mine_haikus_path(format: :text)
      expect(response).to have_http_status(:ok)
      expect(
        response.content_type
      ).to include('text/plain')
    end
  end

  describe 'GET /haikus/pending_review' do
    context '管理者の場合' do
      it '評価待ち一覧が表示されること' do
        log_in_as(admin)
        create(:haiku, :submitted)
        get pending_review_haikus_path
        expect(response).to have_http_status(:ok)
      end
    end

    context '一般ユーザーの場合' do
      it 'リダイレクトされること' do
        log_in_as(user)
        get pending_review_haikus_path
        expect(response).to redirect_to(root_url)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        get pending_review_haikus_path
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'POST /haikus（管理者投稿）' do
    it '管理者投稿の俳句が作成されること' do
      log_in_as(user)
      expect do
        post haikus_path, params: {
          haiku: {
            body: 'ふるいけやかわずとびこむみず',
            kigo: '蛙',
            status: 'submitted_to_admin'
          }
        }
      end.to change(Haiku, :count).by(1)
      expect(
        Haiku.last.submitted_to_admin?
      ).to be true
    end
  end
end
