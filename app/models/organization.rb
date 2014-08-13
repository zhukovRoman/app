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

  def residue_summ_for_all_objects
    return ObjectFinanceByWorkType.where(organization_name: self.name).sum('SummaRabot-PayFact')||0
  end

  def work_complete_summ_for_all_objects
    return ObjectFinanceByWorkType.where(organization_name: self.name).sum('VipolnenoRabot')||0
  end

  def work_left_summ_for_all_objects
    return ObjectFinanceByWorkType.where(organization_name: self.name).sum('PayFact-VipolnenoRabot')||0
  end

  def get_tenders
    return ObjectTender.where(organization_id: self.id)
  end
end
