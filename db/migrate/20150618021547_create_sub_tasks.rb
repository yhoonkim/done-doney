class CreateSubTasks < ActiveRecord::Migration
  def change
    create_table :sub_tasks do |t|

      t.datetime :original_created_at
      t.integer :created_by_id

      t.integer :task_id
      t.integer :revision

      t.string :title
      t.integer :completed_by_id
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
