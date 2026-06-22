class CreateKigoExplanations < ActiveRecord::Migration[7.1]
  def change
    create_table :kigo_explanations do |t|
      t.string :kigo_word, null: false
      t.string :canonical_word
      t.string :parent_kigo
      t.string :season, null: false
      t.text :explanation

      t.timestamps
    end

    add_index :kigo_explanations, :kigo_word, unique: true
  end
end
