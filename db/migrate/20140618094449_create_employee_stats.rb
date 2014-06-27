class CreateEmployeeStats < ActiveRecord::Migration
  def change
    create_table :employee_stats_months do |t|
      t.date :month
      t.float :salary, :precision => 15, :scale => 10
      t.float :bonus, :precision => 15, :scale => 10
      t.float :tax, :precision => 15, :scale => 10
      t.float :avg_salary, :precision => 15, :scale => 10

      t.float :salary_manage, :precision => 15, :scale => 10
      t.float :bonus_manage, :precision => 15, :scale => 10
      t.float :tax_manage, :precision => 15, :scale => 10
      t.float :avg_salary_manage, :precision => 15, :scale => 10

      t.integer :employee_count
      t.integer :employee_adds
      t.integer :employee_dismiss
      t.integer :vacancy_count

      t.integer :employee_manage_count
      t.integer :employee_production_count

      t.float :k_dismiss, :precision => 15, :scale => 10
      t.float :k_complect, :precision => 15, :scale => 10
      t.timestamps
    end

    create_table :employee_stats_departments do |t|
      t.date :month
      t.belongs_to :department
      t.float :salary, :precision => 15, :scale => 10
      t.float :bonus, :precision => 15, :scale => 10
      t.float :tax, :length => 15, :decimals => 12
      t.float :avg_salary, :length => 15, :decimals => 12

      t.integer :employee_count
      t.integer :vacancy_count
      t.timestamps
    end
  end
end
