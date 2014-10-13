class ApartmentController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Продажи"
  end

  def index2
    render "apartment_fake_data/index2"
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

    @apartmetns = Array.new
    @objects = Array.new
    data['GetBuildingGroupsResult']['buildinggroups'].each do |obj|
      @objects.push obj['name']
      obj['buildings'].each do |build|
        build['sections'].each do |sec|
          sec['apartments'].each do |apart|
            if apart['status']=='Другое'
              next
            end
            a = Hash.new
            a['id']=apart['id']
            a['object']=obj['name']
            a['floor']=apart['floor']
            a['max_floor']=sec['floors']
            a['rooms']=apart['rooms']
            a['square']=apart['spaceDesign']
            #a['price_m2_start']=apart['cost']
            #a['price_m2_end']=apart['dpCost']
            a['price_m2_start']=(apart['sum']||0)/(apart['spaceDesign']||1)
            a['price_m2_contract']=(apart['orderSum']||(apart['sum']||0))/(apart['spaceDesign']||1)
            a['price_m2_end']=(apart['dpSum']||0)/(apart['spaceDesign']||1)
            a['free_date']=apart['apIsFreeDate']
            a['has_qty_date']=apart['apHasDemandDate']
            a['in_sing_date']=apart['apInSignDate']
            a['auction_date']=apart['auctionDateTime']
            a['sale_plan_date']=apart['salesOrderPlanDate']
            a['dkp_date']=apart['salesOrderDate']
            a['ps_date']=apart['ownCertificateDateOfIssue']
            a['sum']=apart['sum']
            a['order_sum']=apart['orderSum']||apart['sum']
            a['end_sum']=apart['dpSum']
            a['hypotec']=apart['isHypothec']
            a['bankName'] = apart['hypothecBankid']||'Личные средства'
            a['finishing']=apart['finishingLevel']
            a['fee']=apart['brokersFeeWithNDS']
            a['status']=apart['status']
            #if (a['auction_date']!=nil && Date.parse(a['auction_date'].to_s)>(Date.current - 5.day))
            #  puts a
            #end
            if (a['hypotec']==true)
              puts a
            end
            @apartmetns.push(a)
          end
        end
      end
    end
    @objects.sort

    #Apartment.all.each do |apart|
    #  @apartmetns.push apart.to_json
    #end

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
