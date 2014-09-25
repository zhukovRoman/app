class Organization < ActiveRecord::Base
  Organization.establish_connection :mssqlObjects

  Organization.table_name = 'vw_ObjectForMobileInfoOrganizationsList'
  self.primary_key = 'OrganizationId'

  alias_attribute 'id' , 'OrganizationId'
  alias_attribute 'name' , 'OrganizationName'
  alias_attribute 'full_name' , 'OrganizationNameFull'

  has_many :objs, foreign_key: 'OrganizationGenBuilder_ID'
  has_many :object_tenders, foreign_key: 'TenderOrganization'

  def objects
    return Obj.where(general_builder: self.name)
  end

  def self.get_all_info
    Organization.includes(:objs)
  end
  def payed_for_all_objects (objs)
    summ = 0
    objs.each do |o|
        summ += 0
    end
    return summ
  end

  #остаток оплаты
  def residue_summ_for_all_objects
    return (ObjectFinanceByWorkType.where(organization_name: self.name).sum('SummaRabot') - ObjectFinanceByWorkType.where(organization_name: self.name).sum('PayFact'))||0
  end


  def work_complete_summ_for_all_objects
    return ObjectFinanceByWorkType.where(organization_name: self.name).sum('VipolnenoRabot')||0
  end

  def work_left_summ_for_all_objects
    #return ObjectFinanceByWorkType.where(organization_name: self.name).sum('SummaRabot-VipolnenoRabot')||0
    return ((ObjectFinanceByWorkType.where(organization_name: self.name).sum('SummaRabot')||0) -
        (ObjectFinanceByWorkType.where(organization_name: self.name).sum('VipolnenoRabot')||0))||0
  end

  #оплачено
  def payed_for_work_for_all_objects
    #return ObjectFinanceByWorkType.where(organization_name: self.name).sum('PayFact-AvansVidano')||0
    return (ObjectFinanceByWorkType.where(organization_name: self.name).sum('PayFact') -ObjectFinanceByWorkType.where(organization_name: self.name).sum('AvansVidano'))||0
  end

  def avans_vidano_for_all_objects
    return ObjectFinanceByWorkType.where(organization_name: self.name).sum('AvansVidano')||0
  end

  def avans_pagasheno_for_all_objects
    return ObjectFinanceByWorkType.where(organization_name: self.name).sum('AvansPogasheno')||0
  end

  def avans_not_pagasheno_for_all_objects
    #return ObjectFinanceByWorkType.where(organization_name: self.name).sum('AvansVidano-AvansPogasheno')||0
    return (ObjectFinanceByWorkType.where(organization_name: self.name).sum('AvansVidano') - ObjectFinanceByWorkType.where(organization_name: self.name).sum('AvansPogasheno'))||0
  end

  def get_tenders
    return ObjectTender.where(organization_id: self.id)
  end

  def getOrgPartsInTendersByYears
    tendersByYears = Hash.new
    self.object_tenders.where(status: 'проведен').
        group("YEAR(DataFinish)").distinct('ObjectID').count.each do |year, countT|
      tendersByYears[year]=tendersByYears[year]||Hash.new
      tendersByYears[year]['count']=countT
    end

    self.object_tenders.where(status: 'проведен').
        group("YEAR(DataFinish)").sum('TenderPriceEnd').each do |year, summT|
      tendersByYears[year]=tendersByYears[year]||Hash.new
      tendersByYears[year]['sum']=summT
    end
    return tendersByYears
  end
end
