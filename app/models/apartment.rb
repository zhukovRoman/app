class Apartment < ActiveRecord::Base
  belongs_to :section

  def self.create_or_update_from_json json, section_id
    id = json['id']
    apart = Apartment.find_by out_id: id
    if (apart ==nil)
      apart = Apartment.new
      apart.out_id = id
    end
    apart.section_id = section_id
    apart.floor = json['floor']
    apart.rooms = json['rooms']
    apart.balcony_сount = json['balconyCount']
    apart.loggia_сount = json['loggiaCount']
    apart.before_bti_number = json['beforeBTINumber']
    apart.spaces_bti_wo_balcony = json['spaceDesign']
    apart.total_plot_area = json['spaceLiving']
    apart.space_wo_balcony = json['spaceBTIKitchen']
    apart.dp_cost = json['dpCost']
    apart.summ = json['sum']
    apart.finish_summ = json['dpSum']
    apart.is_hypothec = json['isHypothec']
    apart.bank_name = json['hypothecBankid']
    apart.finishing = json['finishingLevel']
    apart.realtor = json['realtor']
    apart.realtor_fee = json['brokersFeeWithNDS']
    apart.status = json['status']
    #puts json['status'];
    apart.update_status_dates
    apart.save
  end

  def update_status_dates
    if self.status=='ПС' && self.ps_date == nil
      self.ps_date = (Date.current)
    end
    if self.status == 'ДКП' && self.dkp_date == nil
      self.dkp_date = Date.current
    end
    if self.status == 'Аукцион' && self.auction_date == nil
      self.auction_date = Date.current
    end
    if self.status == 'Имеет заявку' && self.has_qty_date == nil
      self.has_qty_date = Date.current
    end
    if self.status == 'Свободна' && self.free_date == nil
      self.free_date = Date.current
    end
    if self.status == 'Не в продаже' && self.not_sale_date == nil
      self.not_sale_date = Date.current
    end

  end

  def to_json
    apartment = Hash.new
    apartment['rooms']=rooms
    apartment['status']=status
    apartment['floor']=floor
    apartment['square']=spaces_bti_wo_balcony
    apartment['summ']=summ
    apartment['start_m2']=(summ||0)/(spaces_bti_wo_balcony||1)
    apartment['end_summ']=finish_summ
    apartment['end_m2']=(finish_summ||0)/(spaces_bti_wo_balcony||1)
    apartment['price_diff']=(finish_summ||0)-(summ||0)
    apartment['ps_date']=ps_date
    apartment['dkp_date']=dkp_date
    apartment['auction_date']=auction_date
    apartment['has_qty_date']=has_qty_date
    apartment['free_date']=free_date
    apartment['not_sale_date']=not_sale_date
    apartment['realtor_fee']=realtor_fee
    return apartment
  end
end
