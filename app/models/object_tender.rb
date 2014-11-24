class ObjectTender < ActiveRecord::Base
  ObjectTender.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfoTenders'
  self.primary_key = 'TenderId'

  belongs_to :obj, foreign_key: 'ObjectID'
  belongs_to :organization, foreign_key: 'TenderOrganization'

  alias_attribute 'object_id','ObjectID'
  alias_attribute 'tender_id', 'TenderId'
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
  alias_attribute 'number','TenderNum'

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
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept=1').count(:tender_id).each do |k,v|
      item['data'].push(v)
    end
    res.push(item)

    item = Hash.new
    item['name']='от 2 до 4 заявок'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept>1 and TenderQtyAccept<5').count(:tender_id).each do |k,v|
      item['data'].push(v)
    end
    res.push(item)

    item = Hash.new
    item['name']='5 заявок и более'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept>4').count(:tender_id).each do |k,v|
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
    item['name']='от 2 до 4 заявок'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept>1 and TenderQtyAccept<5').sum(:price_end).each do |k,v|
      item['data'].push((v/(1000*1000*1000)).round 3)
    end
    res.push(item)

    item = Hash.new
    item['name']='5 заявок и более'
    item['data']=Array.new
    ObjectTender.group('Year(DataFinish)').where('TenderQtyAccept>4').sum(:price_end).each do |k,v|
      item['data'].push((v/(1000*1000*1000)).round 3)
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

  def self.get_qty_tenders_drilldown_by_year year
    months = ['Янв', 'Фев', 'Март', 'Апр', 'Май', 'Июнь', 'Июль', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек']
    res = Hash.new

    res['count']=Hash.new
    res['sum']=Hash.new

    res['count']['one']=Array.new
    res['count']['two_four']=Array.new
    res['count']['g_four']=Array.new

    res['sum']['one']=Array.new
    res['sum']['two_four']=Array.new
    res['sum']['g_four']=Array.new

    puts ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept=1').
             group('MONTH(DataFinish)').count(:tender_id)
    ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept=1').
                                                      group('MONTH(DataFinish)').count(:tender_id).each do |k,v|
      res['count']['one'].push [months[k-1],v]
    end
    ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept>1 and TenderQtyAccept<5').
                                                      group('MONTH(DataFinish)').count(:tender_id).each do |k,v|
      res['count']['two_four'].push [months[k-1],v]
    end
    ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept>4').
                                                      group('MONTH(DataFinish)').count(:tender_id).each do |k,v|
      res['count']['g_four'].push [months[k-1],v]
    end

    ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept=1').
        group('MONTH(DataFinish)').sum(:price_end).each do |k,v|
      res['sum']['one'].push [months[k-1],(v/(1000*1000*1000)).round(3)]
    end
    ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept>1 and TenderQtyAccept<5').
        group('MONTH(DataFinish)').sum(:price_end).each do |k,v|
      res['sum']['two_four'].push [months[k-1],(v/(1000*1000*1000)).round(3)]
    end
    ObjectTender.where('YEAR(DataFinish)='+year.to_s).where('TenderQtyAccept>4').
        group('MONTH(DataFinish)').sum(:price_end).each do |k,v|
      res['sum']['g_four'].push [months[k-1],(v/(1000*1000*1000)).round(3)]
    end
    return res;
  end

  def self.get_summ_drilldown_by_year year
    data = [{"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
            {"y"=>0, "percent"=>0},
          ]
    res = [data,data]


    ObjectTender.select('MONTH(DataFinish) as month, sum(TenderPriceBegin) as summ_begin, avg(TenderProcentDecline) as pp, sum(TenderPriceEnd) as summ_end')
                .where('YEAR(DataFinish)='+year.to_s)
                .group('MONTH(DataFinish)')
                .each do |data|
                  res[0][data.month-1]['y']=data.summ_begin
                  res[0][data.month-1]['percent']=data.pp
                  res[1][data.month-1]['y']=data.summ_end

    end
    #puts res[0]#.to_json.html_safe
    return res
  end
end
