class Buildinggroup < ActiveRecord::Base
  has_many :buildings


  def self.create_or_update_from_json (json)
    id = json['id']
    group = Buildinggroup.find_by out_id: id
    if (group ==nil)
      group = Buildinggroup.new
      group.out_id = id
    end
    group.address = json['addressBuild']
    group.name = json['name']
    group.start_build_date = json['startBuilding']
    group.end_build_date = json['deadline']
    group.end_sales_date = json['completionSales']
    group.square = json['square']
    group.save;
    json['buildings'].each do |b|
      Building.create_or_update_from_json b, group.id
    end
  end
end
