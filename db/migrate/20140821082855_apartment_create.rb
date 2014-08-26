class ApartmentCreate < ActiveRecord::Migration
  def change
    create_table :buildinggroups do |t|
      t.string :out_id, limit: 500
      t.string :name, limit: 500
      t.string :address, limit: 1000
      t.string :start_build_date, limit: 150
      t.string :end_build_date, limit: 150
      t.string :end_build_date, limit: 150
      t.string :end_sales_date, limit: 150
      t.float  :square, :length => 15, :decimals => 12
      t.timestamps
    end

    create_table :buildings do |t|
      t.string :out_id, limit: 500
      t.string :name, limit: 500
      t.string :address, limit: 1000
      t.string :building_type, limit: 150
      t.timestamps
      t.belongs_to :buildinggroup
    end

    create_table :sections do |t|
      t.string :out_id, limit: 500
      t.integer :number
      t.integer :floors
      t.integer :apartments_on_floor
      t.timestamps
      t.belongs_to :building
    end

    create_table :apartments do |t|
      t.string :out_id, limit: 500
      t.integer :floor
      t.integer :rooms
      t.integer :balcony_сount
      t.integer :loggia_сount
      t.integer :before_bti_number
      t.float :spaces_bti_wo_balcony, :length => 15, :decimals => 12
      t.float :total_plot_area, :length => 15, :decimals => 12
      t.float :space_wo_balcony, :length => 15, :decimals => 12
      t.float :dp_cost, :length => 15, :decimals => 12
      t.float :summ, :length => 15, :decimals => 12
      t.float :finish_summ, :length => 15, :decimals => 12
      t.boolean :is_hypothec
      t.string :bank_name
      t.boolean :finishing
      t.string :realtor, limit: 500
      t.float :realtor_fee, :length => 15, :decimals => 12
      t.string :status, limit: 200
      t.belongs_to :section

      t.string :not_sale_date, limit: 200
      t.string :free_date, limit: 200
      t.string :has_qty_date, limit: 200
      t.string :auction_date, limit: 200
      t.string :dkp_date, limit: 200
      t.string :ps_date, limit: 200
      t.timestamps
    end


  end
end
