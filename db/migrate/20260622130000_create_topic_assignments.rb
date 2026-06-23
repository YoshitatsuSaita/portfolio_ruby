class CreateTopicAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :topic_assignments do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :user, null: false, foreign_key: true
      t.string :theme, null: false
      t.text :message
      t.boolean :read, default: false, null: false

      t.timestamps
    end
  end
end
