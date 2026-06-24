class HaikusController < ApplicationController
  before_action :logged_in_user
  before_action :set_haiku,
                only: %i[show edit update destroy]
  before_action :correct_haiku_user,
                only: %i[edit update]
  before_action :correct_haiku_owner,
                only: :destroy
  before_action :viewable_haiku, only: :show
  before_action :admin_user, only: :pending_review

  def index
    @haikus = Haiku.visible
                   .includes(:user)
                   .order(created_at: :desc)
    @haikus = filter_haikus(@haikus)
              .paginate(page: params[:page])
  end

  def show
    @reviews = @haiku.reviews.includes(:user)
                     .joins(:user)
                     .order(Arel.sql('users.admin DESC'), created_at: :asc)
    @review = current_user_review || @haiku.reviews.build
  end

  def new
    @haiku = current_user.haikus.build(theme: params[:theme])
    @from_topic = params[:topic_assignment_id].present?
  end

  def edit
    @from_topic = @haiku.theme.present? &&
                  current_user.topic_assignments.exists?(theme: @haiku.theme)
  end

  def create
    @haiku = current_user.haikus.build(haiku_params)
    if @haiku.save
      flash[:info] = "同じお題「#{@haiku.theme}」の以前の投稿を下書きに戻し、差し替えました。" if @haiku.replaced_previous
      flash[:success] = '俳句を投稿しました。'
      redirect_to @haiku
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @haiku.update(haiku_params)
      flash[:info] = "同じお題「#{@haiku.theme}」の以前の投稿を下書きに戻し、差し替えました。" if @haiku.replaced_previous
      flash[:success] = '俳句を更新しました。'
      redirect_to @haiku
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @haiku.destroy
    flash[:success] = '俳句を削除しました。'
    redirect_to haikus_url
  end

  def mine
    @haikus = current_user.haikus.order(created_at: :desc)
    respond_to do |format|
      format.html do
        @haikus = @haikus.paginate(page: params[:page])
      end
      format.text { send_text(@haikus) }
    end
  end

  def pending_review
    @haikus = Haiku.pending_review
                   .includes(:user)
                   .order(created_at: :desc)
                   .paginate(page: params[:page])
  end

  private

  def set_haiku
    @haiku = Haiku.find(params[:id])
  end

  def haiku_params
    params.require(:haiku).permit(
      :body, :kigo, :theme,
      :description, :status
    )
  end

  def correct_haiku_user
    unless @haiku.user == current_user
      flash[:danger] = '権限がありません。'
      return redirect_to root_url
    end

    return unless @haiku.reviewed_by_admin?

    flash[:danger] = '管理者の評価済みのため編集できません。'
    redirect_to @haiku
  end

  def correct_haiku_owner
    return if @haiku.user == current_user

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  def viewable_haiku
    return if @haiku.published?
    return if @haiku.user == current_user
    return if current_user.admin?

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  def current_user_review
    @haiku.reviews.find_by(user: current_user)
  end

  def filter_haikus(haikus)
    haikus = haikus.by_theme(params[:theme]) if params[:theme].present?
    haikus = haikus.by_author(params[:author]) if params[:author].present?
    haikus = haikus.by_body(params[:body]) if params[:body].present?
    haikus
  end

  def send_text(haikus)
    text = Haiku.to_text(haikus)
    send_data text,
              filename: "haikus_#{Time.current.strftime('%Y%m%d')}.txt",
              type: 'text/plain; charset=utf-8'
  end
end
