class AddColumnsToManagersStats < ActiveRecord::Migration
  def change
    change_table :employee_stats_months do |t|
      t.float :manager_avg_salary, :length => 15, :decimals => 12
      t.integer :AUP_count
    end
  end
end
