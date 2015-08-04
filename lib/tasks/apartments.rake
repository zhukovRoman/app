namespace :apartments do
  task update: :environment do

    require 'net/http'
    require 'json'

    token = Apartment.get_token
    puts "Token = #{token}"
    if token==nil
      return
    end
    url_path = 'http://172.20.10.10:91/BuildingGroupService.svc/GetBuildingGroups?oauth_consumer_key=test&hash_key='+token.to_s
    puts 'start getting json…'
    url = URI.parse(url_path)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.read_timeout = 10000 #Default is 60 seconds
      http.request(req)
    }


    if res.body != nil
      File.open('from_crm.json', 'w') { |file| file.write(res.body.force_encoding('UTF-8')) }
    end

    puts 'getting data complete!'
  end
end
