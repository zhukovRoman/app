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

  def self.list
    orgs = [];
    Organization.all.each do |o|
      orgs << {
          id: o.id,
          name: o.name,
          object_count: (o.objs.count||0).to_s,
          contest_win_count: (o.object_tenders.count||0).to_s,
          ceo: 'ФИО Генерального Директора',
          address: 'Юр Адрес'
      }
    end
    orgs
  end

  def self.contacts
    contacts = [];
    Organization.all.each do |o|
      contacts << {
          contractor_id: o.id,
          type: 1,
          value: '8-888-888-88-88'
      }
      contacts << {
          contractor_id: o.id,
          type: 2,
          value: 'mail@mail.com'
      }
    end
    contacts
  end

  def self.organizations_budjets
    orgs = [];
    Organization.all.each do |o|
      orgs << {
          contractor_id: o.id,
          payed: o.work_complete_summ_for_all_objects,
          left: o.work_left_summ_for_all_objects
      }
    end
    orgs
  end

  def self.organizations_parts_in_sum
    orgs = [];
    Organization.all.each do |o|
      o.object_tenders.where(status: 'проведен').
          group("YEAR(DataFinish)").sum('TenderPriceEnd').each do |year, summT|
        orgs << {
            contractor_id: o.id,
            date: Date.parse("#{year}-01-01").to_time.to_i,
            sum: summT
        }
      end
    end
    orgs
  end

  def self.organizations_parts_in_amount
    orgs = [];
    Organization.all.each do |o|
      o.object_tenders.where(status: 'проведен').
          group("YEAR(DataFinish)").distinct('ObjectID').count.each do |year, count|
        orgs << {
            contractor_id: o.id,
            date: Date.parse("#{year}-01-01").to_time.to_i,
            count: count
        }
      end
    end
    orgs
  end

  def self.organizations_payment
    orgs = [];
    Organization.all.each do |o|
      orgs << {
          contractor_id: o.id,
          prepay_payed: o.avans_pagasheno_for_all_objects,
          prepay_not_payed: o.avans_not_pagasheno_for_all_objects,
          normal_payed: o.payed_for_work_for_all_objects,
          left_to_pay: o.residue_summ_for_all_objects
      }
    end
    orgs
  end

  def self.organizations_contracts
    contracts = []
    Obj.all.each do |obj|
      next if obj.organization.nil?
      contracts << {
          contractor_id: obj.organization.try(:id),
          object_id: obj.id,
          status: obj.status_name,
          network: "#{obj.SMR_external_network||'-'}/#{obj.SMR_external_network_delay||0}",
          erection: "#{obj.SMR_constructive||'-'}/#{obj.SMR_constructive_delay||0}",
          finishing: "#{obj.SMR_internal||'-'}/#{obj.SMR_internal_delay||0}"
      }
    end
    contracts
  end


end
