class AddDeadlineToTopicAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :topic_assignments, :deadline, :date
  end
end
