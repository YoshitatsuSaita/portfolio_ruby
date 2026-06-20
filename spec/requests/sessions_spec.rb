require 'rails_helper'

RSpec.describe 'Sessions' do
  let(:user) { create(:user) }

  describe 'GET /login' do
    it 'ログインページが表示されること' do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /login' do
    context '有効な認証情報の場合' do
      it 'ログインしてリダイレクトされること' do
        post login_path, params: {
          session: {
            email: user.email,
            password: 'password',
            remember_me: '0'
          }
        }
        expect(response).to redirect_to(user)
      end
    end

    context '無効な認証情報の場合' do
      it 'ログインページが再表示されること' do
        post login_path, params: {
          session: {
            email: user.email,
            password: 'wrong',
            remember_me: '0'
          }
        }
        expect(response).to have_http_status(
          :unprocessable_content
        )
      end
    end
  end

  describe 'DELETE /logout' do
    it 'ログアウトしてリダイレクトされること' do
      post login_path, params: {
        session: {
          email: user.email,
          password: 'password',
          remember_me: '0'
        }
      }
      delete logout_path
      expect(response).to redirect_to(root_url)
    end
  end
end
