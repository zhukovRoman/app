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
    ws = self.work_summ||0
    pf = self.pay_fact||0
    return ((ws-pf)||0).round
  end

  def work_left
    return ((self.pay_fact-self.work_comlete)||0).round
  end

  def payed_for_work
    pf = self.pay_fact||0
    av = self.avans_vidano||0
    return ((pf - av)||0).round
  end

  def in_avance_work
    av = self.avans_vidano||0
    ap = (self.avans_pogasheno||0)
    return (av - ap).round
  end

  def work_with_avance
    wc = self.work_comlete||0
    av = self.avans_vidano||0
    ap = self.avans_pogasheno||0
    return ((wc - ( av - ap))||0).round
  end
end
