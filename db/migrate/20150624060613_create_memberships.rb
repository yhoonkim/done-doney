class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.integer :list_id
      t.integer :user_id
      t.integer :revision
      t.string  :state
      t.boolean :owner
      t.boolean :muted

      t.timestamps null: false
    end
  end
end
