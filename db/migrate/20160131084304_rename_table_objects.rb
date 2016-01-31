class RenameTableObjects < ActiveRecord::Migration
  def self.up
    rename_table :objects, :construction_objects
  end 
  def self.down
    rename_table :construction_objects, :objects
  end
end
