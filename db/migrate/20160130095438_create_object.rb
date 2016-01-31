class CreateObject < ActiveRecord::Migration
  def change
    create_table :objects do |t|
      t.integer :out_id
      t.string  :object_name
      t.string  :podotrasl
      t.string  :seria
      t.string  :prefektura
      t.float   :latitude
      t.float   :longitude
      t.float   :total_space
      t.float   :living_space
      t.float   :total_places
      t.float   :car_places
      t.float   :road_length
      t.integer :floor_count
      t.integer :one_room_count
      t.integer :two_room_count
      t.integer :three_room_count
      t.integer :four_room_count
      t.string  :is_there_a_wreckage
      t.date    :planning_comissioning_date
      t.float   :cost_limit
      t.float   :current_year_limit
      t.date    :techincal_state_date
      t.string  :technical_state

      t.timestamps
    end
  end
end
