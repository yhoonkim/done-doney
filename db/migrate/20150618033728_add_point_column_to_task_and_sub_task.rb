class AddPointColumnToTaskAndSubTask < ActiveRecord::Migration
  def change
    add_column :tasks, :point, :integer
    add_column :sub_tasks, :point, :integer
  end
end
