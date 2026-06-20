class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def set_user
    @user = User.find(params[:id])
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'ログインしてください。'
    redirect_to login_url
  end

  def correct_user
    return if current_user?(@user)

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  def correct_or_admin_user
    return if current_user.admin? || current_user?(@user)

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end
end
