class Obj < ActiveRecord::Base
  Obj.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfo_NEW'
  self.primary_key = 'ObjectId'

  has_one :object_finance, foreign_key: 'ObjectId'
  has_one :object_document, foreign_key: 'ObjectId'
  has_one :object_prepare, foreign_key: 'ObjectId'
  has_one :organization, foreign_key: 'OrganizationGenBuilder_ID'
  has_many :object_finance_by_work_types, foreign_key: 'ObjectID'
  has_many :object_tenders, foreign_key: 'ObjectID'
  has_many :visit_infos, foreign_key: 'ObjectId'
  has_many :object_photos, foreign_key: 'ObjId'

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


  @@objects_types_hierarchy
  @@objects_regions

  def address
    adress
  end

  def in_aip?
    (self.year_correct||'').start_with?('20') ? 0 : 1
  end

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

  def complete_date
    self.year_correct.nil? ? nil : Date.parse("#{self.year_correct}-01-01").to_time.to_i
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

  def getBankGarantStatus
    status = 'Погашена'
    self.object_finance_by_work_types.each do |wtype|
      if wtype.bank_garanty_status != status
        return 'Просрочено'
      end
    end
    return status;
  end

  def getDestroyStatus
    if (self.demolition_date_plan==nil && self.demolition_date==nil)
      return 'Не требуется'
    end
    if (self.demolition_date!=nil)
      return 'Выпоненен'
    end
    if(self.demolition_date_plan!=nil && self.demolition_date==nil && Date.parse(self.demolition_date_plan.to_s)>Date.current)
      return 'Требуется'
    end
    if(self.demolition_date_plan!=nil && self.demolition_date==nil && Date.parse(self.demolition_date_plan.to_s)<Date.current)
      return 'Просрочено'
    end
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
    return Obj.where(is_archive: 0).includes(:object_finance).includes(:object_document).includes(:object_finance_by_work_types)
  end

  def get_object_finance_by_type (type)
    if (type==1)
      return ObjectFinanceByWorkType.where(work_type: 'СМР', object_id: self.id)
    else
      return ObjectFinanceByWorkType.where.not(work_type: 'СМР').where(object_id: self.id).group('ObjectId')
    end

  end

  def appointment_adaptive
    if (appointment=='Гаражи' || appointment=='Прочие объекты')
      return 'Прочие'
    end
    appointment
  end

  def self.overdueObjects
    return Obj.where('ObjectArchve = 0').includes(:object_document)#.where("DataPlanGPZU < ?", Date.current )
  end

  def self.getAllAppointmentType
    return Obj.select('appointment').distinct
  end

  def self.objects_types_hierarchy
    @@objects_types_hierarchy = [
      {id:1, parent_id: 0, name:'Жилище'},
      {id:2, parent_id: 1, name:'Жилье'},
      {id:3, parent_id: 1, name:'Инженерия'},
      {id:4, parent_id: 0, name:'Социальные объекты'},
      {id:5, parent_id: 4, name:'БНК'},
      {id:6, parent_id: 4, name:'ДОУ'},
      {id:7, parent_id: 4, name:'Спорт - ФОК'},
      {id:8, parent_id: 4, name:'ФОК'},
      {id:9, parent_id: 4, name:'Школа'},
      {id:10, parent_id: 4, name:'Поликлиника'},
      {id:11, parent_id: 0, name:'Прочее'},
      {id:12, parent_id: 11, name:'Дороги'},
      {id:13, parent_id: 11, name:'Переход'},
      {id:14, parent_id: 11, name:'Прочие'},
    ]
  end

  def self.objects_regions
    @@objects_regions = []
    Obj.select(:region).distinct.each_with_index do |r, i|
      @@objects_regions.push ({:name => r.region, :id => i+1})
    end
    @@objects_regions
  end

  def self.land_passports
    gpzus = []
    ObjectDocument.all.each do |doc|
      gpzus.push ({id: doc.object_id, object_id: doc.object_id,
                   expected_receive_date:doc.GPZU_plan.nil? ? nil : doc.GPZU_plan.to_time.to_i,
                   real_receive_date: doc.GPZU_fact.nil? ? nil : doc.GPZU_fact.to_time.to_i
                 })
    end
    gpzus
  end

  def self.expertises
    expertises = []
    ObjectDocument.all.each do |doc|
      expertises.push ({id: doc.object_id, object_id: doc.object_id,
                   expected_receive_date:doc.MGE_plan.nil? ? nil : doc.MGE_plan.to_time.to_i,
                   real_receive_date: doc.MGE_fact.nil? ? nil : doc.MGE_fact.to_time.to_i
                 })
    end
    expertises
  end

  def self.permits
    permits = []
    ObjectDocument.all.each do |doc|
      permits.push ({id: doc.object_id, object_id: doc.object_id,
                   expected_receive_date:doc.razrezh_build_plan.nil? ? nil : doc.razrezh_build_plan.to_time.to_i,
                   real_receive_date: doc.razrezh_build_fact.nil? ? nil : doc.razrezh_build_fact.to_time.to_i
                 })
    end
    permits
  end

  def self.demolitions
    demolitions = []
    Obj.all.each do |o|
      demolitions.push ({id: o.id, object_id: o.id,
                     expected_receive_date:o.demolition_date_plan.nil? ? nil : o.demolition_date_plan.to_time.to_i,
                     real_receive_date: o.demolition_date.nil? ? nil : o.demolition_date.to_time.to_i,
                     status: o.demolition_status
                   })
    end
    demolitions
  end

  def self.all_objects_json
    objs = []
    Obj.all.each do |o|
      puts o.appointment
      objs.push({
          :id => o.id,
          :region_id => @@objects_regions.find_index {|item| item[:name] == o.region} + 1,
          :type_id => @@objects_types_hierarchy.find_index {|item|
                    item[:name].mb_chars.downcase == o.appointment_adaptive.mb_chars.downcase} + 1,
          :address => o.address,
          :is_archive => o.is_archive ? 1 : 0,
          :date => o.complete_date,
          :latitude => o.lat,
          :longitude => o.lng,
          :power => o.power,
          :power_unit_name => o.power_measure,
          :without_date => o.in_aip?
      })
    end
    objs
  end


  def self.api_response
    {
        :objectType => Obj.objects_types_hierarchy,
        :objectRegion => Obj.objects_regions,
        :objects => Obj.all_objects_json,
        :landPassport => Obj.land_passports,
        :expertise => Obj.expertises,
        :buildingPermit => Obj.permits,
      # - Банковская гарантия ()
      # Поля: id (int), object_id (int), expected_receive_date (timestamp), real_receive_date (timestamp)
        :bankGuarantee => nil,
        :buildingDemolition => Obj.demolitions,
      # - Работы по объекту ()
      #  Поля:
      #  - id (int)
      #  - object_id (int)
      #  - price (int)
      #  - type (int) (1 = обычных платеж, 2 = в счет авансов)
      #  - payed (int) сколько выплачено
        :works => nil
    }
  end





end
