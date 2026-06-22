class CreateHaikus < ActiveRecord::Migration[7.1]
  def change
    create_table :haikus do |t|
      t.references :user, null: false, foreign_key: true
      t.string :body, null: false
      t.string :kigo, null: false
      t.integer :season, null: false
      t.string :theme
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
