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
    return ((self.work_summ - self.pay_fact)||0).round
  end

  def work_left
    return ((self.pay_fact-self.work_comlete)||0).round
  end

  def payed_for_work
    return ((self.pay_fact||0-self.avans_vidano||0)||0).round
  end

  def in_avance_work
    #return 0
    return ((self.avans_vidano||0) - (self.avans_pogasheno||0)).round
  end

  def work_with_avance
    return ((self.work_comlete||0 - (self.avans_vidano||0 - self.avans_pogasheno||0))||0).round
  end
end
