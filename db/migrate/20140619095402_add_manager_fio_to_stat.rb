class AddManagerFioToStat < ActiveRecord::Migration
  def change
    change_table :employee_stats_departments do |t|
      t.string :manager, limit: 500
    end
  end
end
