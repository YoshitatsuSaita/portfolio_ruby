class KigoExplanation < ApplicationRecord
  validates :kigo_word, presence: true, uniqueness: true
  validates :season, presence: true

  def none_season?
    season == 'none'
  end
end
