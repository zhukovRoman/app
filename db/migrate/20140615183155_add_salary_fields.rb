class AddSalaryFields < ActiveRecord::Migration
  def change
    change_table :salaries do |t|
      t.float :NDFL, :length => 15, :decimals => 12
      t.float :insurance, :length => 15, :decimals => 12
      t.float :retention, :length => 15, :decimals => 12
    end
  end
end
