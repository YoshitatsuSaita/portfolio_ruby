class Haiku < ApplicationRecord
  belongs_to :user

  validates :body, presence: true,
                   length: { minimum: 5, maximum: 30 }
  validates :kigo, presence: true
  validates :status, presence: true

  enum :status, {
    draft: 0,
    published: 1,
    submitted_to_admin: 2
  }

  scope :visible, -> { published }
  scope :by_theme, ->(t) { where(theme: t) }
end
