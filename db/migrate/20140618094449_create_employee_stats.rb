class CreateEmployeeStats < ActiveRecord::Migration
  def change
    create_table :employee_stats_months do |t|
      t.date :month
      t.float :salary, :length => 15, :decimals => 12
      t.float :bonus, :length => 15, :decimals => 12
      t.float :tax, :length => 15, :decimals => 12
      t.float :avg_salary, :length => 15, :decimals => 12

      t.float :salary_manage, :length => 15, :decimals => 12
      t.float :bonus_manage, :length => 15, :decimals => 12
      t.float :tax_manage, :length => 15, :decimals => 12
      t.float :avg_salary_manage, :length => 15, :decimals => 12

      t.integer :employee_count
      t.integer :employee_adds
      t.integer :employee_dismiss
      t.integer :vacancy_count

      t.integer :employee_manage_count
      t.integer :employee_production_count

      t.float :k_dismiss, :length => 15, :decimals => 12
      t.float :k_complect, :length => 15, :decimals => 12
      t.timestamps
    end

    create_table :employee_stats_departments do |t|
      t.date :month
      t.belongs_to :department
      t.float :salary, :length => 15, :decimals => 12
      t.float :bonus, :length => 15, :decimals => 12
      t.float :tax, :length => 15, :decimals => 12
      t.float :avg_salary, :length => 15, :decimals => 12

      t.integer :employee_count
      t.integer :vacancy_count
      t.timestamps
    end
  end
end
