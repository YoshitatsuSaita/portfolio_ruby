class AddChildKigoToKigoExplanations < ActiveRecord::Migration[7.1]
  def change
    add_column :kigo_explanations, :child_kigo, :text
  end
end
