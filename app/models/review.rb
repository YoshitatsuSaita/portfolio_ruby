class Review < ApplicationRecord
  belongs_to :user
  belongs_to :haiku

  validates :score, presence: true,
                    inclusion: { in: 1..5,
                                 allow_nil: true }
  validates :user_id,
            uniqueness: { scope: :haiku_id }

  validate :cannot_review_own_haiku

  after_create :publish_if_admin_review

  private

  def cannot_review_own_haiku
    return unless user_id == haiku&.user_id

    errors.add(:base, '自分の俳句には評価できません。')
  end

  def publish_if_admin_review
    return unless user.admin?
    return unless haiku.submitted_to_admin?

    haiku.published!
  end
end
