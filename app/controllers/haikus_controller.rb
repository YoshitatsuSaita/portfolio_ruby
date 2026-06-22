class HaikusController < ApplicationController
  before_action :logged_in_user
  before_action :set_haiku,
                only: %i[show edit update destroy]
  before_action :correct_haiku_user,
                only: %i[edit update destroy]

  def index
    @haikus = Haiku.visible
                   .includes(:user)
                   .order(created_at: :desc)
    @haikus = filter_haikus(@haikus)
              .paginate(page: params[:page])
  end

  def show; end

  def new
    @haiku = current_user.haikus.build
  end

  def edit; end

  def create
    @haiku = current_user.haikus.build(haiku_params)
    if @haiku.save
      flash[:success] = '俳句を投稿しました。'
      redirect_to @haiku
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @haiku.update(haiku_params)
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
    @haikus = current_user.haikus
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
    return if @haiku.user == current_user

    flash[:danger] = '権限がありません。'
    redirect_to root_url
  end

  def filter_haikus(haikus)
    haikus = haikus.by_theme(params[:theme]) if params[:theme].present?
    haikus
  end
end
