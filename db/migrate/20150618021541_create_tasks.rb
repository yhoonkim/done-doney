class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :assignee_id
      t.integer :assigner_id
      t.datetime :original_created_at
      t.integer :created_by_id
      t.date :due_date
      t.integer :list_id
      t.integer :revision
      t.boolean :starred
      t.string :title
      t.integer :completed_by_id
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
