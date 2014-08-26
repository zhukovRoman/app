class Section < ActiveRecord::Base
  has_many :apartments
  belongs_to :building

  def self.create_or_update_from_json (json, building_id)
    id = json['id']
    section = Section.find_by out_id: id
    if (section ==nil)
      section = Section.new
      section.out_id = id
    end
    section.building_id = building_id
    section.number = json['sectionNumber']
    section.floors = json['floors']
    section.apartments_on_floor = json['apartmentsOnFloor']
    section.save
    json['apartments'].each do |s|
     Apartment.create_or_update_from_json s, section.id
    end
  end
end
