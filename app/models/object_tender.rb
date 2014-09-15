class ObjectTender < ActiveRecord::Base
  ObjectTender.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfoTenders'
  self.primary_key = 'TenderId'

  belongs_to :obj, foreign_key: 'ObjectID'
  has_one :organization, foreign_key: 'OrganizationId'

  alias_attribute 'object_id','ObjectID'
  alias_attribute 'status','TenderStatus'
  alias_attribute 'date_declaration','DataDeclaration'
  alias_attribute 'date_start','DataStart'
  alias_attribute 'date_finish','DataFinish'
  alias_attribute 'price_begin','TenderPriceBegin'
  alias_attribute 'price_end','TenderPriceEnd'
  alias_attribute 'percent_decline','TenderProcentDecline'
  alias_attribute 'price_m2_start','TenderPriceBeginOne'
  alias_attribute 'price_m2_end','TenderPriceEndOne'
  alias_attribute 'type','TenderSName'
  alias_attribute 'organization_id','TenderOrganization'
  alias_attribute 'bid_all','TenderQtyPresent'
  alias_attribute 'bid_accept','TenderQtyAccept'

  #def obj
  #  return Obj.where(object_id = self.object_id)
  #end

  def isUkOnly
    if (self.type=='управляющая компания' && ObjectTender.where(object_id: self.object_id).count==1)
      #  по объекту существует всего 1 конкурс и тот на УК
      return true;
    end
    return false;
  end

  def isWithoutUk
    if (ObjectTender.where(object_id: self.object_id, type: 'управляющая компания').count==0)
    #  по объекту не было торогов на УК
      return true
    end
    return false;
  end

  def self.frendly_date (date)
    date =  Date.parse(date.to_s(:db))
    return date.year.to_s+"-"+date.month.to_s+"-"+date.day.to_s
  end

  def self.get_qty_tenders_count
    res=Array.new
    item = Hash.new
    item['name']='1 заявка'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=1').count(:object_id).each do |k,v|
      item['data'].push(v)
    end
    res.push(item)

    item = Hash.new
    item['name']='2 заявки'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=2').count(:object_id).each do |k,v|
      item['data'].push(v)
    end
    res.push(item)

    item = Hash.new
    item['name']='3 заявки'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=3').count(:object_id).each do |k,v|
      item['data'].push(v)
    end
    res.push(item)

    item = Hash.new
    item['name']='4 заявки и более'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept>3').count(:object_id).each do |k,v|
      item['data'].push(v)
    end
    res.push(item)

    return res.reverse
  end

  def self.get_qty_tenders_sum
    res=Array.new
    item = Hash.new
    item['name']='1 заявка'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=1').sum(:price_end).each do |k,v|
      item['data'].push((v/(1000*1000*1000)).round 3)
    end
    res.push(item)

    item = Hash.new
    item['name']='2 заявки'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=2').sum(:price_end).each do |k,v|
      item['data'].push((v/(1000*1000*1000)).round 3)
    end
    res.push(item)

    item = Hash.new
    item['name']='3 заявки'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=3').sum(:price_end).each do |k,v|
      item['data'].push((v/(1000*1000*1000)).round 3)
    end
    res.push(item)

    item = Hash.new
    item['name']='4 заявки и более'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept>3').sum(:price_end).each do |k,v|
      item['data'].push((v/(1000*1000*1000)).round(3))
    end
    res.push(item)

    return res.reverse
  end

  def self.uk_m2_price
    res = Array.new
    ObjectTender.select('AVG (TenderPriceEndOne) as avg').where("TenderSName = 'управляющая компания'").group('YEAR (DataFinish)').each do |v|
      res.push (v.avg/1000).round
    end
    return res
  end
  def self.uk_m2_price
    res = Array.new
    ObjectTender.select('AVG (TenderPriceEndOne) as avg').where("TenderSName = 'управляющая компания'").group('YEAR (DataFinish)').each do |v|
      res.push (v.avg/1000).round
    end
    return res
  end

  def self.gen_m2_price
    res = Array.new
    ObjectTender.select('AVG (TenderPriceEndOne) as avg').where("TenderSName = 'генподрядчик'").group('YEAR (DataFinish)').each do |v|
      res.push (v.avg/1000).round
    end
    return res
  end

end
