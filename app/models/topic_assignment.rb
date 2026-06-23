class TopicAssignment < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :user

  validates :theme, presence: true
  validate :deadline_not_in_past

  private

  def deadline_not_in_past
    return if deadline.blank?

    errors.add(:deadline, 'は今日以降の日付を指定してください') if deadline < Date.current
  end

  scope :unread, -> { where(read: false) }
end
