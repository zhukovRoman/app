class CreateVacancies < ActiveRecord::Migration
  def change
    create_table :vacancies do |t|
      t.integer :count
      t.belongs_to :department
      t.date :for_date
      t.timestamps
    end
  end
end
