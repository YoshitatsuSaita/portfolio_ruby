class GuestsController < ApplicationController
  def create
    user = find_or_create_guest(
      email: 'guest@example.com',
      name: 'ゲストユーザー'
    )
    log_in user
    flash[:success] = 'ゲストとしてログインしました。'
    redirect_to root_path
  end

  def create_admin
    user = find_or_create_guest(
      email: 'guest_admin@example.com',
      name: 'ゲスト管理者',
      admin: true
    )
    log_in user
    flash[:success] = 'ゲスト管理者としてログインしました。'
    redirect_to root_path
  end

  private

  def find_or_create_guest(email:, name:, admin: false)
    User.find_or_create_by!(email: email) do |u|
      u.name = name
      u.password = SecureRandom.urlsafe_base64(16)
      u.guest = true
      u.admin = admin
      u.profile_text = 'ゲストとしてログインしています。'
    end
  end
end
