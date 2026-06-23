class TopicAssignment < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :user

  validates :theme, presence: true

  scope :unread, -> { where(read: false) }
end
