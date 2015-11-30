class ObjectFinance < ActiveRecord::Base
  ObjectFinance.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfoFinance'
  self.primary_key = 'ObjectId'

  has_one :obj, foreign_key: 'ObjectId'

  alias_attribute 'year_limit', 'TitulTekYear'
  alias_attribute 'pay_current_year','PayTekYear'
  alias_attribute 'in_contract', 'SumRabot'
  alias_attribute 'contract_payed', 'SumPayRabot'
  alias_attribute 'prepayment_take','AvansVidano'
  alias_attribute 'prepayment_complite','AvansPogasheno'
  alias_attribute 'complete_work', 'WorkVipilneno'
  alias_attribute 'sumAIP', 'SumAIP'
  alias_attribute 'sum_titul_current_year', 'SumTitulTekYear'
  


  #def incomplete_work
  #  return self.pay_current_year||0-self.complete_work||0
  #end

  def payed
    return in_contract||0
  end

  def payed_without_avans
    return (contract_payed||0) - (prepayment_take||0)
  end

  def avans_pogasheno
    return prepayment_complite||0
  end

  def avans_ne_pogasheno
    return (prepayment_take||0)-(prepayment_complite||0)
  end

  def payed_left
    return (in_contract||0)-(contract_payed||0)
  end

  def work_left
    return (in_contract||0)-(complete_work||0)
  end

  def limit_residue
    return (sum_titul_current_year||0)-(pay_current_year||0)
  end

  def object_payment_json
    {
        id: id,
        object_id: obj.id,
        prepay_payed: avans_pogasheno,
        prepay_not_payed: avans_ne_pogasheno,
        normal_payed: payed_without_avans,
        left_to_pay: payed_left
    }
  end

  def object_budjets
    {
        id: id,
        object_id: obj.id,
        budjet: sum_titul_current_year||0,
        budjet_spent: pay_current_year||0
    }
  end

  def object_perfomance
    {
        id: obj.id,
        object_id: obj.id,
        payed: payed||0,
        left: work_left||0
    }
  end


end
