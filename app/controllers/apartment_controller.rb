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

    #finance_status_data = Hash.new
    #finance_status_data['valueSuffix']='млн руб';
    #finance_status_data['y-axis-label']='Млн рублей';
    #finance_status_data['all-rooms']=Hash.new
    #finance_status_data['1-rooms']=Hash.new
    #finance_status_data['2-rooms']=Hash.new
    #finance_status_data['3-rooms']=Hash.new
    finish = Hash.new;
    notFinish = Hash.new;

    rooms = Hash.new

    data['GetBuildingGroupsResult']['buildinggroups'].each do |pro|
      finish[pro['name']] = 0
      notFinish[pro['name']] = 0
      rooms[pro['name']] = Hash.new

      pro['buildings'].each do |b|
        b['sections'].each do |s|
          s['apartments'].each do |a|
            if (a['status']=='ПС' || a['status']=='ДКП')
              finish[pro['name']] += a['finishingLevel']==true ? 1 : 0
              notFinish[pro['name']] += a['finishingLevel']==true ? 0 : 1

              times = Hash.new
              times['reserveFactData']=a['reserveFactData']
              times['auctionEndFactDate']=a['auctionEndFactDate']
              times['dpDateForRegistration']=a['dpDateForRegistration']
              times['dpDateForRegistrationPlanned']=a['dpDateForRegistrationPlanned']
              times['ownCertificateDateOfIssue']=a['ownCertificateDateOfIssue']
              times['sertificateDateOfIssue']=a['certificateDateOfIssue']
              puts times
            end

            if rooms[pro['name']][a['rooms']]==nil
              rooms[pro['name']][a['rooms']] = Hash.new
              rooms[pro['name']][a['rooms']]['sell'] = 0
              rooms[pro['name']][a['rooms']]['notsell'] = 0;
            end

            if (a['status']=='ДКП' || a['status']=='ПС' || a['status']=='Аукцион' )
              rooms[pro['name']][a['rooms']]['sell'] += 1
            else
              rooms[pro['name']][a['rooms']]['notsell'] += 1
            end


          end
        end
      end
    end

    #puts finish
    #puts notFinish
    #puts rooms
    render "index2"
  end

  def crm
    token = ApartmentController.get_token
    if (token==nil )
      render plain: 'error (get_token)'
    else
      data = ApartmentController.get_apartments_json(token)
      puts data.to_json
      File.open('test.json', 'w') { |file| file.write(data.to_json) }
      data['GetBuildingGroupsResult']['buildinggroups'].each do |pro|
        Buildinggroup.create_or_update_from_json pro
      end
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
    require 'net/http'
    require 'json'

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
