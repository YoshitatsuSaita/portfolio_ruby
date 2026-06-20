require 'rails_helper'

RSpec.describe 'Users' do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }

  def log_in_as(login_user)
    post login_path, params: {
      session: {
        email: login_user.email,
        password: 'password',
        remember_me: '0'
      }
    }
  end

  describe 'GET /signup' do
    it '新規登録ページが表示されること' do
      get signup_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /users' do
    context '有効なパラメータの場合' do
      it 'ユーザーが作成されること' do
        expect do
          post users_path, params: {
            user: {
              name: 'Test User',
              email: 'test-new@example.com',
              password: 'password',
              password_confirmation: 'password'
            }
          }
        end.to change(User, :count).by(1)
      end
    end

    context '無効なパラメータの場合' do
      it 'ユーザーが作成されないこと' do
        expect do
          post users_path, params: {
            user: {
              name: '',
              email: 'invalid',
              password: 'short',
              password_confirmation: 'wrong'
            }
          }
        end.not_to change(User, :count)
      end
    end
  end

  describe 'GET /users' do
    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        get users_path
        expect(response).to redirect_to(login_url)
      end
    end

    context '一般ユーザーの場合' do
      it 'トップにリダイレクトされること' do
        log_in_as(user)
        get users_path
        expect(response).to redirect_to(root_url)
      end
    end

    context '管理者の場合' do
      it '一覧が表示されること' do
        log_in_as(admin)
        get users_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /users/:id' do
    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        get user_path(user)
        expect(response).to redirect_to(login_url)
      end
    end

    context '本人の場合' do
      it 'プロフィールが表示されること' do
        log_in_as(user)
        get user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /users/:id' do
    context '他人のプロフィールを編集しようとした場合' do
      it 'リダイレクトされること' do
        log_in_as(user)
        patch user_path(other_user), params: {
          user: { name: 'Hacked' }
        }
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'DELETE /users/:id' do
    context '管理者が他のユーザーを削除する場合' do
      it 'ユーザーが削除されること' do
        log_in_as(admin)
        other_user
        expect do
          delete user_path(other_user)
        end.to change(User, :count).by(-1)
      end
    end

    context '管理者が自分自身を削除しようとした場合' do
      it '削除されないこと' do
        log_in_as(admin)
        expect do
          delete user_path(admin)
        end.not_to change(User, :count)
      end
    end
  end
end
