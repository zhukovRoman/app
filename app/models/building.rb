class Building < ActiveRecord::Base
  has_many :sections
  belongs_to :buildinggroup

  def self.create_or_update_from_json (json, building_group_id)
    id = json['id']
    build = Building.find_by out_id: id
    if (build ==nil)
      build = Building.new
      build.out_id = id
    end
    build.buildinggroup_id = building_group_id
    build.name = json['name']
    build.address = json['addressBuild']
    build.building_type = json['realtyType']
    build.save
    json['sections'].each do |s|
       Section.create_or_update_from_json s, build.id
    end
  end
end
