class Haiku < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy

  validates :body, presence: true,
                   length: { minimum: 5, maximum: 30 }
  validates :kigo, presence: true, length: { maximum: 20 }
  validates :status, presence: true

  enum :status, {
    draft: 0,
    published: 1,
    submitted_to_admin: 2,
    pending_publication: 3
  }

  attr_accessor :replaced_previous

  before_save :revert_previous_submission, if: :submitted_to_admin?
  after_save :mark_topic_assignment_read, if: :submitted_to_admin?

  scope :visible, -> { published }
  scope :pending_review, -> { submitted_to_admin }
  scope :by_theme, ->(t) { where('theme LIKE ?', "%#{sanitize_sql_like(t)}%") }
  scope :by_author, lambda { |name|
    joins(:user).where('users.name LIKE ?', "%#{sanitize_sql_like(name)}%")
  }
  scope :by_body, lambda { |text|
    where('body LIKE ?', "%#{sanitize_sql_like(text)}%")
  }

  def reviewed_by_admin?
    reviews.joins(:user).where(users: { admin: true }).exists?
  end

  def revert_previous_submission
    return if theme.blank?

    previous = self.class.where(user_id: user_id, theme: theme,
                                status: :submitted_to_admin)
    previous = previous.where.not(id: id) if persisted?
    self.replaced_previous = previous.exists?
    previous.update_all(status: self.class.statuses[:draft])
  end

  def mark_topic_assignment_read
    return if theme.blank?

    user.topic_assignments.unread.where(theme: theme).update_all(read: true)
  end

  def self.to_text(haikus)
    haikus.map do |h|
      "#{h.body}　（季語: #{h.kigo}）"
    end.join("\n")
  end
end
