class AddTimeZoneColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, default: "Seoul"
  end
end
