class AddRevisionColumnToAuthorization < ActiveRecord::Migration
  def change
    add_column :authorizations, :root_revision, :integer, default: 0
  end
end
