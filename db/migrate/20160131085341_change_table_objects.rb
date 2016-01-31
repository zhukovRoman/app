class ChangeTableObjects < ActiveRecord::Migration
  def change
    change_column :construction_objects, :out_id, :integer, limit: 8
  end
end
