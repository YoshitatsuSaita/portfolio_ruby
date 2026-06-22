class RemoveSeasonFromHaikus < ActiveRecord::Migration[7.1]
  def change
    remove_column :haikus, :season, :integer
  end
end
