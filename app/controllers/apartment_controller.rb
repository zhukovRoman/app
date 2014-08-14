class ApartmentController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Продажи"
  end

  def index2

  end

  def index
    #puts current_user.inspect()
    authorize! :index, self
    data = ''
    file = File.new("test.json", "r")
    while (line = file.gets)
      data += line
    end
    file.close
    require 'json'
    data = JSON.parse(data)
    puts data['GetBuildingGroupsResult']['date']
    render "index2"
  end

  def crm
    token = ApartmentController.get_token
    if (token==nil )
      render plain: 'error (get_token)'
    else
      data = ApartmentController.get_apartments_json(token)
      File.open('test.json', 'w') { |file| file.write(data.to_s) }
      render plain: "ok"
    end
  end

  private
  def self.get_token
    require 'net/http'
    require 'json'

    uri = URI('http://172.20.10.10:91/BuildingGroupService.svc/Authenticate?oauth_consumer_key=test')
    resp = Net::HTTP.get(uri) # => String
    result = JSON.parse(resp)
    if result == nil
      return nil
    end
    return result['AuthenticateResult']
  end

  def self.get_apartments_json (token)
    url_path = 'http://172.20.10.10:91/BuildingGroupService.svc/GetBuildingGroups?oauth_consumer_key=test&hash_key='+token.to_s
    uri = URI(url_path)
    resp = Net::HTTP.get(uri) # => String
    result = JSON.parse(resp)
    if result == nil
      return nil
    end
    return result
  end
end
