class CreateDb < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :FIO, limit: 500
      t.string :tab_number, limit: 20
      t.float :stavka, :length => 15, :decimals => 12
      t.string :post
      t.timestamps
    end

    create_table :salaries do |t|
      t.float :salary, :length => 15, :decimals => 12
      t.float :bonus, :length => 15, :decimals => 12
      t.float :tax, :length => 15, :decimals => 12
      t.date :salary_date
      t.float :add_salary, :length => 15, :decimals => 12

      t.timestamps
    end

    create_table :departments do |t|
      t.string :out_number
      t.string :name
      t.integer :vacancy_count
      t.timestamps
    end

    create_table :personal_flows do |t|
      t.string :operation_type
      t.string :new_post
      t.string :old_post
      t.date :flow_date

      t.timestamps
    end

    change_table :employees do |t|
      t.belongs_to :department

    end

    change_table :salaries do |t|
      t.belongs_to :employee
    end

    change_table :departments do |t|
      t.belongs_to :employee
      t.references :department
      rename_column :departments, :department_id, :parent_id
      rename_column :departments, :employee_id, :chief_id
    end

    change_table :personal_flows do |t|
      t.belongs_to :employee
      t.belongs_to :department
      rename_column :personal_flows, :department_id, :old_department_id
      t.belongs_to :department
      rename_column :personal_flows, :department_id, :new_department_id
    end

  end
end
