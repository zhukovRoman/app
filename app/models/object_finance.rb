class ObjectFinance < ActiveRecord::Base
  ObjectFinance.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfoFinance"
  self.primary_key = "ObjectId"

  has_one :obj, foreign_key: "ObjectId"

  alias_attribute "year_limit", "TitulTekYear"
  alias_attribute "pay_current_year","PayTekYear"
  alias_attribute "in_contract", "SumRabot"
  alias_attribute "contract_payed", "SumPayRabot"
  alias_attribute "prepayment_take","AvansVidano"
  alias_attribute "prepayment_complite","AvansPogasheno"
  alias_attribute "complete_work", "WorkVipilneno"
  alias_attribute "sumAIP", "SumAIP"


  #def incomplete_work
  #  return self.pay_current_year||0-self.complete_work||0
  #end

  def payed
    return in_contract||0
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
    return (in_contract||0)-(prepayment_complite||0)-(complete_work||0)
  end


end
