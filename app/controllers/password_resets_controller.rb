class PasswordResetsController < ApplicationController
  before_action :set_user,   only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'パスワード再設定用のメールを送信しました。'
      redirect_to root_url
    else
      flash.now[:danger] = 'メールアドレスが見つかりません。'
      render 'new', status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_content
    elsif @user.update(user_params)
      log_in @user
      @user.update_columns(reset_digest: nil)
      flash[:success] = 'パスワードが再設定されました。'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    return if @user&.authenticated?(:reset, params[:id])

    flash[:danger] = '無効なリンクです。'
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'パスワード再設定の有効期限が切れています。もう一度やり直してください。'
    redirect_to new_password_reset_url
  end
end
