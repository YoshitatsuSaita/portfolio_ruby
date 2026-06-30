class UsersController < ApplicationController
  before_action :set_user,
                only: %i[show edit update destroy]
  before_action :logged_in_user,
                only: %i[index show edit update destroy]
  before_action :correct_or_admin_user, only: %i[edit update]
  before_action :admin_user, only: :destroy
  before_action :prevent_self_destroy, only: :destroy
  before_action :prevent_admin_destroy, only: :destroy
  before_action :prevent_guest_edit, only: %i[edit update]
  before_action :prevent_guest_destroy, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @haiku_count = @user.haikus.published.count
    @reviewed_count = @user.haikus.published.joins(reviews: :user)
                          .where(users: { admin: true }).distinct.count
  end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = 'ユーザー情報を更新しました。'
      redirect_to @user
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(
      :name, :email, :profile_text,
      :password, :password_confirmation
    )
  end

  def prevent_self_destroy
    return unless current_user?(@user)

    flash[:danger] = '自分自身を削除することはできません。'
    redirect_to users_url
  end

  def prevent_admin_destroy
    return unless @user.admin?

    flash[:danger] = '管理者は削除できません。'
    redirect_to users_url
  end

  def prevent_guest_edit
    return unless @user.guest?

    flash[:danger] = 'ゲストユーザーの編集はできません。'
    redirect_to user_url(@user)
  end

  def prevent_guest_destroy
    return unless @user.guest?

    flash[:danger] = 'ゲストユーザーは削除できません。'
    redirect_to users_url
  end
end
