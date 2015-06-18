class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|

      t.datetime :original_created_at
      t.string :title
      t.string :list_type
      t.string :type
      t.integer :revision
      t.string :name
      t.timestamps null: false
    end
  end
end
