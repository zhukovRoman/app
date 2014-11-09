class AddDepNameToStat < ActiveRecord::Migration
  def change
    change_table :employee_stats_departments do |t|
      t.string :dep_name, limit: 500
    end
  end
end
