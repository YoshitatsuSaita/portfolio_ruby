class Haiku < ApplicationRecord
  belongs_to :user
  has_many :reviews, dependent: :destroy

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
  scope :pending_review, -> { submitted_to_admin }
  scope :by_theme, ->(t) { where(theme: t) }

  def reviewed_by_admin?
    reviews.joins(:user).where(users: { admin: true }).exists?
  end

  def self.to_csv(haikus)
    require 'csv'
    CSV.generate do |csv|
      csv << %w[句 季語 お題 作者メモ 公開設定 投稿日]
      haikus.each do |h|
        csv << [
          h.body, h.kigo, h.theme, h.description,
          h.status, h.created_at.strftime('%Y-%m-%d')
        ]
      end
    end
  end

  def self.to_text(haikus)
    haikus.map do |h|
      "#{h.body}　（季語: #{h.kigo}）"
    end.join("\n")
  end
end
