class Obj < ActiveRecord::Base
  Obj.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfo_NEW'
  self.primary_key = 'ObjectId'

  has_one :object_finance, foreign_key: 'ObjectId'
  has_one :object_document, foreign_key: 'ObjectId'
  has_one :object_prepare, foreign_key: 'ObjectId'
  has_one :organization, foreign_key: 'OrganizationGenBuilder_ID'
  has_many :object_finance_by_work_types, foreign_key: 'ObjectID'
  has_many :object_tenders, foreign_key: 'ObjectId'
  has_many :visit_infos, foreign_key: 'ObjectId'

  alias_attribute 'id','ObjectId' #
  #АДрес
  alias_attribute 'region' , 'ObjectRegionName'
  alias_attribute 'seria' , 'ObjectSerialName'
  alias_attribute 'adress','ObjectAdress' #
  alias_attribute 'name','ObjectName' #
  alias_attribute 'lat', 'ObjectShirota'
  alias_attribute 'lng', 'ObjectDolgota'

  alias_attribute 'manager','ObjectManager' #
  # лица и учатсники
  alias_attribute 'general_builder', 'OrganizationGenBuilder' #
  alias_attribute 'techinikal_customer', 'OrganizationTehZakaz' #
  alias_attribute 'projector','OrganizationProjector' #проектировщик
  alias_attribute 'build_control','StroiControl' #строй контроль

  alias_attribute 'appointment','ObjectAppointmentName' # Назначение
  alias_attribute 'indastry','ObjectAppointmentType' # Отрасль
  alias_attribute 'budget','ObjectFinanceBudget' #
  alias_attribute 'summ_PPS', 'SumPSS'

  alias_attribute 'is_archive','ObjectArchve' #

  alias_attribute 'data_enter_kontract', 'DataRazreshVvod' # срок ввода по контракту
  alias_attribute 'year_plan','ObjectEnterYearPlan' # факт
  alias_attribute 'year_correct','ObjectEnterYearCorrect' # по плану
  #alias_attribute 'year_DS','ObjectEnterYear' #
  #alias_attribute 'date_of_enter','ObjectDataEnter' #

  alias_attribute 'power','Power' #
  alias_attribute 'power_measure','PowerEdIzm' #

  alias_attribute 'status_name','ObjectStatusName' #

  alias_attribute 'floors','ObjectAmountFloor' #

  alias_attribute 'photo_path','ObjectPhotoPath' #

  alias_attribute 'evacuation_status', 'EvacuationStatus'
  alias_attribute 'evacuation_date', 'ObjectEvacuationDataFact'
  alias_attribute 'evacuation_date_plan', 'ObjectEvacuationDataPlan'

  alias_attribute 'demolition_status', 'DemolitionStatus'
  alias_attribute 'demolition_date', 'ObjectDemolitionDataFact'
  alias_attribute 'demolition_date_plan', 'ObjectDemolitionDataPlan'

  #квартирография
  alias_attribute 'rooms_square', 'SRooms'
  alias_attribute 'count_1k', 'Q1Rooms'
  alias_attribute 'count_2k', 'Q2Rooms'
  alias_attribute 'count_3k', 'Q3Rooms'
  alias_attribute 'count_4k', 'Q4Rooms'

  #Движение по графику производства работ
  alias_attribute 'SMR_external_network', 'SMR_ExternalNetwork'
  alias_attribute 'SMR_external_network_delay', 'SMR_LooserExtern'
  alias_attribute 'SMR_constructive', 'SMR_Constructive'
  alias_attribute 'SMR_constructive_delay', 'SMR_LooserConstr'
  alias_attribute 'SMR_internal', 'SMR_InternalSystems'
  alias_attribute 'SMR_internal_delay', 'SMR_LooserIntern'

  def self.get_years_enters_plan
    return Obj.group('ObjectEnterYearPlan').order(:year_plan).count(:id)
  end

  def self.get_years_enters_fact
    return Obj.group('YEAR(ObjectEnterYearCorrect)').order('YEAR(ObjectEnterYearCorrect)').count(:id)
  end


  def getYearCorrect
    return self.year_correct||'----'
    if self.year_correct == nil
      return '----';
    end
    parts = self.year_correct.to_s.split
    if parts==nil
    end
    return Date.parse(parts[0]).year

  end

  def getVisitsInfo
    return VisitInfo.where(object_id: self.id).order(:object_id, :sort1, :sort2)
  end

  def getGPZUStatus
    return self.object_document.getGPZUStatus
  end

  def getMGEStatus
    return self.object_document.getMGEStatus
  end

  def getRazreshStatus
    return self.object_document.getRazreshStatus
  end

  def self.getAllDistricts
    return Obj.where(is_archive: 0).select('region').distinct
  end

  def organization
    return Organization.find_by(name: self.general_builder)
  end

  def tenders
    return ObjectTender.where(object_id: self.id)
  end
  # todo
  # сделать выбор правильного года
  def self.getAllEnterYears
    res = Array.new
    #Obj.where(is_archive: 0).select('ObjectEnterYearCorrect').each do |o|
    #  if (!res.include?(o.getYearCorrect.to_s))
    #    res.push(o.getYearCorrect.to_s)
    #  end
    #end

    Obj.where(is_archive: 0).select('ObjectEnterYearCorrect').distinct.each do |o|
      res.push(o.year_correct||'----')
    end
    return res
  end

  def self.notArchive
    return Obj.where(is_archive: 0).includes(:object_finance).includes(:object_document)
  end

  def get_object_finance_by_type (type)
    if (type==1)
      return ObjectFinanceByWorkType.where(work_type: 'СМР', object_id: self.id)
    else
      return ObjectFinanceByWorkType.where.not(work_type: 'СМР').where(object_id: self.id).group('ObjectId')
    end

  end

  def self.overdueObjects
    return Obj.where('ObjectArchve = 0').includes(:object_document)#.where("DataPlanGPZU < ?", Date.current )
  end

  def self.getAllAppointmentType
    return Obj.select('appointment').distinct
  end




end
