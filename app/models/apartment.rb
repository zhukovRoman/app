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
    puts json['status'];
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
end
