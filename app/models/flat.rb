class Flat
  @objects
  @data
  @flats
  @flat_statuses
  @flat_dkp_expected
  @realtor_fee
  @flats_id
  def initialize
    data = ''
    file = File.new("from_crm.json", "r")
    while (line = file.gets)
      data += line
    end
    file.close

    require 'json'
    @data = JSON.parse(data)['GetBuildingGroupsResult']['buildinggroups']
    @flats_id = []
    @objects = Array.new
    @data.each_with_index { |obj, i | @objects << {name: obj['name'], id: i+1} }
    @flats = Array.new
    @flat_statuses = Array.new
    @flat_dkp_expected = Array.new
    @realtor_fee = Array.new
    obj_id = 0;
    flat_status_id = 1;
    @data.each do |obj|
      obj_id += 1
      obj['buildings'].each do |build|
        build['sections'].each do |sec|
          sec['apartments'].each do |apart|
            if apart['status']=='Другое'
              next
            end

            @flats << {
                id: Flat.put_flat_id(apart['id']),
                object_id: obj_id,
                apartment_count: apart['rooms'],
                floor: apart['floor'],
                footage: apart['spaceDesign']||1,
                price_start:  apart['sum']||0,
                price_order: (apart['orderSum']||(apart['sum']||0)),
                price_final: (apart['dpSum']||0),
                mortgage: !apart['hypothecBankid'].nil?,
                mortgage_bank: apart['hypothecBankid']
            }
            @flat_statuses << Flat.get_statuses(apart, flat_status_id)
            flat_status_id+=5

            @flat_dkp_expected << {id:flat_status_id, flat_id: Flat.find_flat_id(apart['id']), date:Flat.dete_to_timestamp(apart['salesOrderPlanDate'])}
            @realtor_fee << {date: Flat.dete_to_timestamp(apart['salesOrderDate']), commission:apart['brokersFeeWithNDS']}
          end
        end
      end
    end

  end

  def self.find_flat_id guid
    @flats_id.find_index {|item| item == guid} + 1
  end

  def self.put_flat_id guid
    @flats_id = Array.new if @flats_id.nil?
    @flats_id << guid
    @flats_id.length
  end

  def self.dete_to_timestamp date
    return nil if date.nil?
    Date.parse(date).to_time.to_i
  end

  def self.get_statuses apart, id
    res = []
    if (!apart['apIsFreeDate'].nil?)
      res << {id: id, flat_id: Flat.find_flat_id(apart['id']), date: Flat.dete_to_timestamp(apart['apIsFreeDate']),  status:1}
    end
    if (!apart['apHasDemandDate'].nil?)
      res << {id: id, flat_id: Flat.find_flat_id(apart['id']), date: Flat.dete_to_timestamp(apart['apHasDemandDate']),  status:2}
    end
    if (!apart['auctionDateTime'].nil?)
      res << {id: id, flat_id: Flat.find_flat_id(apart['id']), date: Flat.dete_to_timestamp(apart['auctionDateTime']),  status:3}
    end
    if (!apart['salesOrderDate'].nil?)
      res << {id: id, flat_id: Flat.find_flat_id(apart['id']), date: Flat.dete_to_timestamp(apart['salesOrderDate']),  status:4}
    end
    if (!apart['ownCertificateDateOfIssue'].nil?)
      res << {id: id, flat_id: Flat.find_flat_id(apart['id']), date: Flat.dete_to_timestamp(apart['ownCertificateDateOfIssue']),  status:5}
    end
    # (1 = свободна, 2 = заявка, 3 = аукцион, 4 = ДКП, 5 = ПС
    res
  end

  def objects
    return @objects
  end

  def flats
    @flats
  end

  def statuses
    @flat_statuses
  end

  def dkp_expected
    @flat_dkp_expected
  end

  def fee
    @realtor_fee
  end
end