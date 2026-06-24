class TopicAssignmentsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: %i[new create submission_status destroy]

  def index
    @topic_assignments = current_user.topic_assignments
                                     .includes(:sender)
                                     .order(created_at: :desc)
                                     .paginate(page: params[:page])
  end

  def new
    @users = User.where(admin: false).order(:name)
  end

  def create
    user_ids = params[:user_ids]
    theme = params[:theme]&.strip
    message = params[:message]&.strip.presence
    deadline = params[:deadline].presence

    if user_ids.blank? || theme.blank?
      flash[:danger] = 'ユーザーとお題を入力してください。'
      @users = User.where(admin: false).order(:name)
      return render :new, status: :unprocessable_content
    end

    assignments = User.where(id: user_ids, admin: false).map do |user|
      current_user.sent_topic_assignments.build(
        user: user, theme: theme, message: message, deadline: deadline
      )
    end

    if assignments.any? { |a| a.invalid? }
      flash[:danger] = assignments.find(&:invalid?).errors.full_messages.join('、')
      @users = User.where(admin: false).order(:name)
      return render :new, status: :unprocessable_content
    end

    assignments.each(&:save!)

    flash[:success] = 'お題を送信しました。'
    redirect_to submission_status_topic_assignments_path
  end

  def show
    @topic_assignment = current_user.topic_assignments.find(params[:id])
  end

  def destroy
    assignment = TopicAssignment.find(params[:id])
    TopicAssignment.where(theme: assignment.theme, sender_id: assignment.sender_id).destroy_all
    flash[:success] = 'お題を削除しました。'
    redirect_to submission_status_topic_assignments_path
  end

  def submission_status
    @assignments_by_theme = TopicAssignment.includes(:user)
                                           .order(created_at: :desc)
                                           .group_by(&:theme)
    @haikus_by_key = Haiku.where(theme: @assignments_by_theme.keys)
                          .where(status: %i[submitted_to_admin published])
                          .includes(reviews: :user)
                          .index_by { |h| [h.theme, h.user_id] }
  end
end
