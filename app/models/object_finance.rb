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


  def incomplete_work
    return self.pay_current_year||0-self.complete_work||0
  end
end
