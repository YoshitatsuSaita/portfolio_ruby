class ReviewsController < ApplicationController
  before_action :logged_in_user
  before_action :set_haiku
  before_action :set_review, only: %i[update destroy]
  before_action :correct_review_user,
                only: %i[update destroy]

  def create
    @review = @haiku.reviews.build(review_params)
    @review.user = current_user
    if @review.save
      flash[:success] = '評価を投稿しました。'
      return redirect_to submission_status_topic_assignments_path if @haiku.reload.pending_publication?
    else
      flash[:danger] =
        @review.errors.full_messages.join(', ')
    end
    redirect_to @haiku
  end

  def update
    if @review.update(review_params)
      flash[:success] = '評価を更新しました。'
      return redirect_to submission_status_topic_assignments_path if @haiku.pending_publication? && current_user.admin?
    else
      flash[:danger] = @review.errors.full_messages.join(', ')
    end
    redirect_to @haiku
  end

  def destroy
    @review.destroy
    flash[:success] = '評価を削除しました。'
    redirect_to @haiku
  end

  private

  def set_haiku
    @haiku = Haiku.find(params[:haiku_id])
  end

  def set_review
    @review = @haiku.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(
      :score, :comment,
      :correction_body, :correction_reason
    )
  end

  def correct_review_user
    return if @review.user == current_user

    flash[:danger] = '権限がありません。'
    redirect_to @haiku
  end
end
