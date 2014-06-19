class AddDepType < ActiveRecord::Migration
  def change
    change_table :departments do |t|
      t.integer :department_type, :default => 0
    end
  end
end
