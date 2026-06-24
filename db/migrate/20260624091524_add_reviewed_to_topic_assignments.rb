class AddReviewedToTopicAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :topic_assignments, :reviewed, :boolean, default: false, null: false
  end
end
