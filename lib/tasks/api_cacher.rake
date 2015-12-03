namespace :api_cacher do


  task update_all: :environment do
    Rake::Task['api_cacher:update_staffs'].invoke
    Rake::Task['api_cacher:update_objects'].invoke
    Rake::Task['api_cacher:update_contractors'].invoke
    Rake::Task['api_cacher:update_flats'].invoke
    Rake::Task['api_cacher:update_photos'].invoke
    puts "all done"
  end

  task update_staffs: :environment do
    @response_object = {staff: Staff.new}
    File.open("api_cache/staffs.json", 'w') { |file| file.write(@response_object.to_json) }
  end

  task update_objects: :environment do
    @response_object = {
        objects: Obj.api_response
    }
    File.open("api_cache/objects.json", 'w') { |file| file.write(@response_object.to_json) }
  end

  task update_photos: :environment do
    @response_object = {
        :objectPhoto => ObjectPhoto.objects_photos
    }
    File.open("api_cache/objects_photos.json", 'w') { |file| file.write(@response_object.to_json) }
  end

  task update_contractors: :environment do
    @response_object = {contractors: {
        :contractor => Organization.list,
        :contractorContacts => Organization.contacts,
        :contractorBudget => Organization.organizations_budjets,
        :contractorAuctionSum => Organization.organizations_parts_in_sum,
        :contractorAuctionAmount => Organization.organizations_parts_in_amount,
        :contractorPayment => Organization.organizations_payment,
        :contract => Organization.organizations_contracts
    }}
    File.open("api_cache/contractors.json", 'w') { |file| file.write(@response_object.to_json) }
  end

  task update_flats: :environment do
    res = Flat.new
    @response_object = {
        flat: res.flats,
        flatObject: res.objects,
        flatStatus: res.statuses,
        flatDkpExpectedDate: res.dkp_expected,
        flatRealtorCommission: res.fee
    }
    File.open("api_cache/flats.json", 'w') { |file| file.write(@response_object.to_json) }
  end
end
