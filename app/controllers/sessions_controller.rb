class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(
      email: params[:session][:email].downcase
    )
    if user&.authenticate(params[:session][:password])
      log_in user
      if params[:session][:remember_me] == '1'
        remember(user)
      else
        forget(user)
      end
      redirect_back_or(user)
    else
      flash.now[:danger] = '認証に失敗しました。'
      render 'new', status: :unprocessable_content
    end
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end
