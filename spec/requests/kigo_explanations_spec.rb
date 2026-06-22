require 'rails_helper'

RSpec.describe 'KigoExplanations' do
  let(:user) { create(:user) }
  let(:haiku) { create(:haiku) }

  def log_in_as(login_user)
    post login_path, params: {
      session: {
        email: login_user.email,
        password: 'password',
        remember_me: '0'
      }
    }
  end

  describe 'GET /haikus/:haiku_id/kigo_explanation' do
    context 'DBキャッシュがある場合' do
      before do
        create(
          :kigo_explanation,
          kigo_word: haiku.kigo
        )
      end

      it '季語解説が表示されること' do
        log_in_as(user)
        get haiku_kigo_explanation_path(haiku)
        expect(response).to have_http_status(:ok)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        get haiku_kigo_explanation_path(haiku)
        expect(response).to redirect_to(login_url)
      end
    end

    context 'APIエラーの場合' do
      before do
        service = instance_double(GroqApiService)
        allow(GroqApiService).to receive(:new)
          .and_return(service)
        allow(service).to receive(:explain)
          .and_raise(
            GroqApiService::ApiError, 'API error'
          )
      end

      it 'エラーメッセージが表示されること' do
        log_in_as(user)
        get haiku_kigo_explanation_path(haiku)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
