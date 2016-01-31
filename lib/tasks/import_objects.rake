namespace :import_objects do
  task import: :environment do

    object_list = File.open("importXML/object_data.xml") { |f| Nokogiri::XML(f) }

    object_path = object_list.xpath('//DATA_OBJ/Table1')

    object_names = object_path.map do |node|
      node.children.map{ |n| [n.name, n.text.strip] if n.elem? }.compact.to_h
    end

    object_names.each do |object|
      imported_object = ConstructionObject.find_or_initialize_by(out_id: object['ID_OBJ'].to_i)
      (object['VVOD_PLAN_Y'].blank? or object['VVOD_PLAN_Y'] == '0') ? year = '2000' : year = object['VVOD_PLAN_Y'].to_s
      (object['VVOD_PLAN_M'].blank? or object['VVOD_PLAN_M'] == '0') ? month = '01' : month = object['VVOD_PLAN_M'].to_s
      planning_comissioning_date = (year + "-" + month + "-" + "01 01:00:00").to_datetime
      attrs = {
               out_id: object['ID_OBJ'],
               object_name: object['OBJ_NAME'],
               podotrasl: object['PODOTRASL'],
               seria: object['SERIA'],
               prefektura: object['PREFEKTURA'],
               latitude: object['K_SHIROTA'],
               longitude: object['K_DOLGOTA'],
               total_space: object['M_OB_PL'],
               living_space: object['M_J_PL'],
               total_places: object['M_MEST'],
               car_places: object['M_MASH_MEST'],
               road_length: object['M_DLINA'],
               floor_count: object['ETAJ'],
               one_room_count: object['KV_1'],
               two_room_count: object['KV_2'],
               three_room_count: object['KV_3'],
               four_room_count: object['KV_4'],
               is_there_a_wreckage: object['SNOS'],
               planning_comissioning_date: planning_comissioning_date,
               cost_limit: object['PRED_STOIMOST'],
               current_year_limit: object['LIMIT2016'],
               techincal_state_date: object['TEH_SOST_DATE'],
               technical_state:  object['TEH_SOST']
               }
      imported_object.update_attributes(attrs)
      imported_object.save
    end

  end
end