class ApartmentController < ApplicationController
  #before_filter :authenticate_user!
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
            @apartmetns.push(a)
          end
        end
      end
    end

    data['GetBuildingGroupsResult']['buildinggroups'].each do |obj|
     # puts obj['name']+":"+obj['id']
      obj['buildings'].each do |build|
        build['sections'].each do |sec|
          sec['apartments'].each do |apart|
            puts apart['id']+";"+apart['floor'].to_s+";"+(apart['orderSum']||apart['sum']).to_s+";"+obj['id']
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
            @apartmetns.push(a)
          end
        end
      end
    end
    @objects.sort

    # puts @objects.to_json.html_safe
    # puts @apartmetns.to_json.html_safe


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
      #puts data.to_json fo.write body_text3.force_encoding('ASCII-8BIT').encode('UTF-8')
      File.open('test.json', 'w') { |file| file.write(data.to_json) }
      #data['GetBuildingGroupsResult']['buildinggroups'].each do |pro|
      #  Buildinggroup.create_or_update_from_json pro
      #end
      render plain: "ok"
    end
  end

  private


  def self.get_apartments_json (token)
    require 'net/http'
    require 'json'
    # vvAHSmidd4uB6Zu46tU1v57s6GU=
    url_path = 'http://172.20.10.10:91/BuildingGroupService.svc/GetBuildingGroups?oauth_consumer_key=test&hash_key='+token.to_s
    #link = URI.parse(url_path)
    #request = Net::HTTP::Get.new(link.path)
    #begin
    #  response = Net::HTTP.start(link.host, link.port) {|http|
    #    http.read_timeout = 100 #Default is 60 seconds
    #    http.request(request)
    #  }
    #rescue Net::ReadTimeout => e
    #  puts e.message
    #end
    puts 'start apart'
    url = URI.parse(url_path)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.read_timeout = 1000 #Default is 60 seconds
      http.request(req)
    }


    if res.body == nil
      return nil
    end
    return JSON.parse(res.body.force_encoding("UTF-8"))
  end
end
