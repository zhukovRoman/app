class CreateDb < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :FIO, limit: 500
      t.string :tab_number, limit: 20
      t.decimal :stavka
      t.string :post
      t.timestamps
    end

    create_table :salaries do |t|
      t.decimal :salary
      t.decimal :bonus
      t.decimal :tax
      t.date :salary_date
      t.decimal :add_salary

      t.timestamps
    end

    create_table :departments do |t|
      t.string :name
      t.integer :vacancy_count
      t.timestamps
    end

    create_table :personal_flows do |t|
      t.string :type
      t.string :new_post
      t.string :old_post
      t.date :flow_date

      t.timestamps
    end

    change_table :employees do |t|
      t.belongs_to :departments

    end

    change_table :salaries do |t|
      t.belongs_to :employees
    end

    change_table :departments do |t|
      t.belongs_to :employees
      t.references :departments
      rename_column :departments, :departments_id, :parent_id
      rename_column :departments, :employees_id, :chief_id
    end

    change_table :personal_flows do |t|
      t.belongs_to :employees
      t.references :old_department
      t.references :new_department
    end

  end
end
