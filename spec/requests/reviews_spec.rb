require 'rails_helper'

RSpec.describe 'Reviews' do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:haiku) { create(:haiku, user: other_user) }

  def log_in_as(login_user)
    post login_path, params: {
      session: {
        email: login_user.email,
        password: 'password',
        remember_me: '0'
      }
    }
  end

  describe 'POST /haikus/:haiku_id/reviews' do
    context 'ログイン済みで他人の句の場合' do
      it '評価が作成されること' do
        log_in_as(user)
        expect do
          post haiku_reviews_path(haiku), params: {
            review: { score: 4, comment: '良い句です。' }
          }
        end.to change(Review, :count).by(1)
      end
    end

    context '自分の句の場合' do
      let(:own_haiku) { create(:haiku, user: user) }

      it '評価が作成されないこと' do
        log_in_as(user)
        expect do
          post haiku_reviews_path(own_haiku), params: {
            review: { score: 4 }
          }
        end.not_to change(Review, :count)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        post haiku_reviews_path(haiku), params: {
          review: { score: 4 }
        }
        expect(response).to redirect_to(login_url)
      end
    end

    context '管理者が管理者投稿の句を評価した場合' do
      let(:submitted_haiku) do
        create(:haiku, :submitted, user: user)
      end

      it '句が自動で公開されること' do
        log_in_as(admin)
        post haiku_reviews_path(submitted_haiku), params: {
          review: { score: 3, comment: '良い句です。' }
        }
        expect(
          submitted_haiku.reload
        ).to be_published
      end
    end
  end

  describe 'GET /haikus/:haiku_id/reviews/:id/edit' do
    let!(:review) do
      create(:review, user: user, haiku: haiku)
    end

    context '本人の場合' do
      it '編集フォームが表示されること' do
        log_in_as(user)
        get edit_haiku_review_path(haiku, review)
        expect(response).to have_http_status(:ok)
      end
    end

    context '他人の場合' do
      it 'リダイレクトされること' do
        log_in_as(other_user)
        get edit_haiku_review_path(haiku, review)
        expect(response).to redirect_to(haiku)
      end
    end
  end

  describe 'PATCH /haikus/:haiku_id/reviews/:id' do
    let!(:review) do
      create(:review, user: user, haiku: haiku)
    end

    context '本人の場合' do
      it '評価が更新されること' do
        log_in_as(user)
        patch haiku_review_path(haiku, review), params: {
          review: { score: 5, comment: '最高です。' }
        }
        expect(review.reload.score).to eq(5)
        expect(review.reload.comment).to eq('最高です。')
      end
    end

    context '他人の場合' do
      it 'リダイレクトされること' do
        log_in_as(other_user)
        patch haiku_review_path(haiku, review), params: {
          review: { score: 1 }
        }
        expect(response).to redirect_to(haiku)
      end
    end
  end

  describe 'DELETE /haikus/:haiku_id/reviews/:id' do
    let!(:review) do
      create(:review, user: user, haiku: haiku)
    end

    context '本人の場合' do
      it '評価が削除されること' do
        log_in_as(user)
        expect do
          delete haiku_review_path(haiku, review)
        end.to change(Review, :count).by(-1)
      end
    end

    context '他人の場合' do
      it 'リダイレクトされること' do
        log_in_as(other_user)
        delete haiku_review_path(haiku, review)
        expect(response).to redirect_to(haiku)
      end
    end
  end
end
