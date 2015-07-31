class AddDepartmentType < ActiveRecord::Migration
  def change
    change_table :employee_stats_departments do |t|
      t.string :dep_type, limit: 2, default: 'p'
    end
  end
end
