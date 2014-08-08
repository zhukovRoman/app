class ObjectFinanceByWorkType < ActiveRecord::Base
  ObjectFinanceByWorkType.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfoFinanceVidRabot'
  self.primary_key = 'ID_ObjectDDS'

  #belongs_to :obj, foreign_key: 'ObjectId'

  alias_attribute 'work_type','NameVidRabot'
  alias_attribute 'organization_name','Organization'
  alias_attribute 'document_number','NumDogovor'
  alias_attribute 'document_date','DataDogovor'
  alias_attribute 'work_summ','SummaRabot'
  alias_attribute 'pay_fact','PayFact'
  alias_attribute 'avans_vidano','AvansVidano'
  alias_attribute 'avans_pogasheno','AvansPogasheno'
  alias_attribute 'work_comlete','VipolnenoRabot'
  alias_attribute 'bank_summa','BankSumma'
  alias_attribute 'bank_deadline','SrokBankSumma'
  alias_attribute 'object_id', 'ObjectId'

  def residue_summ
    return (self.work_summ - self.pay_fact).round
  end

  def work_left
    return (self.pay_fact-self.work_comlete).round
  end
end
