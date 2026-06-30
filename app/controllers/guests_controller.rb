class GuestsController < ApplicationController
  def create
    user = User.find_or_create_by!(email: 'guest@example.com') do |u|
      u.name = 'ゲストユーザー'
      u.password = SecureRandom.urlsafe_base64(16)
      u.guest = true
      u.profile_text = 'ゲストとしてログインしています。'
    end
    log_in user
    flash[:success] = 'ゲストとしてログインしました。'
    redirect_to root_path
  end
end
