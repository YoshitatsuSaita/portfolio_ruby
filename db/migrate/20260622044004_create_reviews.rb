class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :haiku, null: false, foreign_key: true
      t.integer :score, null: false
      t.text :comment
      t.string :correction_body
      t.text :correction_reason

      t.timestamps
    end

    add_index :reviews, %i[user_id haiku_id], unique: true
  end
end
