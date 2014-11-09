class AddDismissDate < ActiveRecord::Migration
  def change
    change_table :employees do |t|
      t.date :dismiss_date
    end
  end
end
