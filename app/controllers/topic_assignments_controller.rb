class TopicAssignmentsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: %i[new create edit update submission_status destroy publish_all]

  def index
    @topic_assignments = current_user.topic_assignments.active
                                     .includes(:sender)
                                     .order(created_at: :desc)
                                     .paginate(page: params[:page])
  end

  def new
    @users = User.where(admin: false).order(:id)
  end

  def create
    user_ids = params[:user_ids]
    theme = params[:theme]&.strip
    message = params[:message]&.strip.presence
    deadline = params[:deadline].presence

    if user_ids.blank? || theme.blank?
      flash[:danger] = 'ユーザーとお題を入力してください。'
      @users = User.where(admin: false).order(:id)
      return render :new, status: :unprocessable_content
    end

    assignments = User.where(id: user_ids, admin: false).map do |user|
      current_user.sent_topic_assignments.build(
        user: user, theme: theme, message: message, deadline: deadline
      )
    end

    if assignments.any? { |a| a.invalid? }
      flash[:danger] = assignments.find(&:invalid?).errors.full_messages.join('、')
      @users = User.where(admin: false).order(:id)
      return render :new, status: :unprocessable_content
    end

    assignments.each(&:save!)

    flash[:success] = 'お題を送信しました。'
    redirect_to submission_status_topic_assignments_path
  end

  def show
    @topic_assignment = current_user.topic_assignments.find(params[:id])
  end

  def edit
    @assignment = TopicAssignment.find(params[:id])
    @theme = @assignment.theme
    @deadline = @assignment.deadline
    @existing_user_ids = TopicAssignment.where(theme: @theme, sender_id: @assignment.sender_id)
                                        .pluck(:user_id)
    @users = User.where(admin: false).order(:id)
  end

  def update
    assignment = TopicAssignment.find(params[:id])
    theme = assignment.theme
    sender_id = assignment.sender_id
    submitted_user_ids = params[:user_ids]&.map(&:to_i) || []
    existing_user_ids = TopicAssignment.where(theme: theme, sender_id: sender_id)
                                       .pluck(:user_id)

    ids_to_add = submitted_user_ids - existing_user_ids
    ids_to_remove = existing_user_ids - submitted_user_ids

    User.where(id: ids_to_add, admin: false).each do |user|
      current_user.sent_topic_assignments.create!(
        user: user, theme: theme, message: assignment.message, deadline: assignment.deadline
      )
    end

    if ids_to_remove.any?
      TopicAssignment.where(theme: theme, sender_id: sender_id, user_id: ids_to_remove).destroy_all
    end

    flash[:success] = 'お題を更新しました。'
    redirect_to submission_status_topic_assignments_path
  end

  def destroy
    assignment = TopicAssignment.find(params[:id])
    theme = assignment.theme
    Haiku.where(theme: theme, status: %i[submitted_to_admin pending_publication]).update_all(status: :draft)
    TopicAssignment.where(theme: theme, sender_id: assignment.sender_id).destroy_all
    flash[:success] = 'お題を削除しました。'
    redirect_to submission_status_topic_assignments_path
  end

  def publish_all
    theme = params[:theme]

    if Haiku.where(theme: theme, status: :submitted_to_admin).exists?
      flash[:danger] = "お題「#{theme}」にはまだ評価待ちの句があります。すべて評価してから公開してください。"
      return redirect_to submission_status_topic_assignments_path
    end

    haikus = Haiku.where(theme: theme, status: :pending_publication)
    if haikus.none?
      flash[:warning] = "お題「#{theme}」に公開待ちの句はありません。"
      return redirect_to submission_status_topic_assignments_path
    end

    haikus.update_all(status: :published)
    TopicAssignment.where(theme: theme).destroy_all
    flash[:success] = "お題「#{theme}」の句をすべて公開しました。"
    redirect_to submission_status_topic_assignments_path
  end

  def submission_status
    @assignments_by_theme = TopicAssignment.includes(:user)
                                           .order(created_at: :desc)
                                           .group_by(&:theme)
    @haikus_by_key = Haiku.where(theme: @assignments_by_theme.keys)
                          .where(status: %i[submitted_to_admin pending_publication published])
                          .includes(:user, reviews: :user)
                          .index_by { |h| [h.theme, h.user_id] }
  end
end
