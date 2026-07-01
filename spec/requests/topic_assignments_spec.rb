require 'rails_helper'

RSpec.describe 'TopicAssignments' do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  def log_in_as(login_user)
    post login_path, params: {
      session: {
        email: login_user.email,
        password: 'password',
        remember_me: '0'
      }
    }
  end

  describe 'GET /topic_assignments' do
    context 'ログイン済みの場合' do
      it 'お題通知一覧が表示されること' do
        log_in_as(user)
        get topic_assignments_path
        expect(response).to have_http_status(:ok)
      end
    end

    context '未ログインの場合' do
      it 'ログインページにリダイレクトされること' do
        get topic_assignments_path
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'POST /topic_assignments' do
    context '管理者が有効なパラメータで送信した場合' do
      it 'お題が作成されること' do
        log_in_as(admin)
        expect do
          post topic_assignments_path, params: {
            theme: '秋の風景',
            deadline: 1.week.from_now.to_date.to_s,
            user_ids: [user.id]
          }
        end.to change(TopicAssignment, :count).by(1)
      end

      it '期日が正しく保存されること' do
        log_in_as(admin)
        deadline = 1.week.from_now.to_date
        post topic_assignments_path, params: {
          theme: '秋の風景',
          deadline: deadline.to_s,
          user_ids: [user.id]
        }
        expect(TopicAssignment.last.deadline).to eq(deadline)
      end
    end

    context '管理者が期日なしで送信した場合' do
      it 'お題が作成されること' do
        log_in_as(admin)
        expect do
          post topic_assignments_path, params: {
            theme: '秋の風景',
            deadline: '',
            user_ids: [user.id]
          }
        end.to change(TopicAssignment, :count).by(1)
      end
    end

    context '管理者が過去の期日で送信した場合' do
      it 'お題が作成されないこと' do
        log_in_as(admin)
        expect do
          post topic_assignments_path, params: {
            theme: '秋の風景',
            deadline: 1.day.ago.to_date.to_s,
            user_ids: [user.id]
          }
        end.not_to change(TopicAssignment, :count)
      end
    end

    context 'お題が空の場合' do
      it 'お題が作成されないこと' do
        log_in_as(admin)
        expect do
          post topic_assignments_path, params: {
            theme: '',
            deadline: 1.week.from_now.to_date.to_s,
            user_ids: [user.id]
          }
        end.not_to change(TopicAssignment, :count)
      end
    end

    context 'ユーザーが未選択の場合' do
      it 'お題が作成されないこと' do
        log_in_as(admin)
        expect do
          post topic_assignments_path, params: {
            theme: '秋の風景',
            deadline: 1.week.from_now.to_date.to_s
          }
        end.not_to change(TopicAssignment, :count)
      end
    end

    context '一般ユーザーの場合' do
      it 'リダイレクトされること' do
        log_in_as(user)
        post topic_assignments_path, params: {
          theme: '秋の風景',
          user_ids: [admin.id]
        }
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe 'GET /topic_assignments/:id' do
    context '自分宛のお題の場合' do
      it 'お題詳細が表示されること' do
        log_in_as(user)
        ta = create(:topic_assignment, user: user, sender: admin)
        get topic_assignment_path(ta)
        expect(response).to have_http_status(:ok)
      end
    end

    context '他人宛のお題の場合' do
      it 'アクセスできないこと' do
        log_in_as(user)
        other = create(:user)
        ta = create(:topic_assignment, user: other, sender: admin)
        get topic_assignment_path(ta)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
