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
      redirect_to @haiku.reload.pending_publication? ? submission_status_topic_assignments_path : haiku_path(@haiku)
    else
      render_review_errors('new_review_errors')
    end
  end

  def update
    if @review.update(review_params)
      flash[:success] = '評価を更新しました。'
      redirect_to @haiku.pending_publication? && current_user.admin? ? submission_status_topic_assignments_path : haiku_path(@haiku)
    else
      render_review_errors("review_#{@review.id}_errors")
    end
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

  def render_review_errors(target_id)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          target_id,
          partial: 'reviews/errors', locals: { review: @review }
        ), status: :unprocessable_entity
      end
      format.html do
        flash.now[:danger] = @review.errors.full_messages.join(', ')
        redirect_to @haiku
      end
    end
  end
end
