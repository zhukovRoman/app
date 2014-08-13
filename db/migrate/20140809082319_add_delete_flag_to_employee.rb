class AddDeleteFlagToEmployee < ActiveRecord::Migration
  def change
    change_table :employees do |t|
      t.integer :is_delete, :default => 0
    end
  end
end
