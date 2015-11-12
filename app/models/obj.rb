class Obj < ActiveRecord::Base
  Obj.establish_connection :mssqlObjects

  self.table_name = 'vw_ObjectForMobileInfo_NEW'
  self.primary_key = 'ObjectId'

  has_one :object_finance, foreign_key: 'ObjectId'
  has_one :object_document, foreign_key: 'ObjectId'
  has_one :object_prepare, foreign_key: 'ObjectId'
  has_one :organization, foreign_key: 'OrganizationGenBuilder_ID', primary_key: 'OrganizationId'
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

  # def organization
  #   return Organization.find_by(name: self.general_builder)
  # end

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
    return Obj.where('ObjectArchive = 0').includes(:object_document)#.where("DataPlanGPZU < ?", Date.current )
  end

  def self.getAllAppointmentType
    appointments = Obj.select('appointment').distinct
    puts appointments
    return appointments
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

  def self.banking_garanty_statuses
    infos = []
    Obj.includes(:object_finance_by_work_types).all.each do |o|
      o.object_finance_by_work_types.each do |of|
        infos << of.bank_garanty_info
      end
    end
    infos
  end

  def self.demolitions
    demolitions = []
    Obj.all.each do |o|
      demolitions.push ({id: o.id, object_id: o.id,
                     expected_receive_date:o.demolition_date_plan.nil? ? nil : o.demolition_date_plan.to_time.to_i,
                     real_receive_date: o.demolition_date.nil? ? nil : o.demolition_date.to_time.to_i
                     # status: o.demolition_status
                   })
    end
    demolitions
  end

  def self.all_objects_json
    objs = []
    Obj.all.each do |o|
      objs.push({
          :id => o.id,
          :region_id => @@objects_regions.find_index {|item| item[:name] == o.region} + 1,
          :type_id => @@objects_types_hierarchy.find_index {|item|
                    item[:name].mb_chars.downcase == o.appointment_adaptive.mb_chars.downcase} + 1,
          :address => o.address,
          :plan_id => (o.seria=='ИНД') ? 1 : 2,
          :is_archive => o.is_archive ? 1 : "0",
          :date => o.complete_date,
          :latitude => o.lat,
          :longitude => o.lng,
          :power => o.power,
          :power_unit_name => o.power_measure,
          :without_date => o.in_aip? ? 1 : 0
      })
    end
    objs
  end

  def self.objects_payment
    works = []
    ObjectFinance.all.each do |of|
      works << of.object_payment_json
    end
    works
  end

  def  self.object_perfomance
    perfomance = []
    ObjectFinance.all.each do |of|
      perfomance << of.object_perfomance
    end
    perfomance
  end

  def self.objects_budjets
    payments = []
    ObjectFinance.all.each do |of|
      payments << of.object_budjets
    end
    payments
  end

  def self.teps_list
    [
      {id: 1, name: 'Мощность'},
      {id: 2, name: 'Площадь квартир'},
      {id: 3, name: 'Квартирография'},
      {id: 4, name: 'Этажность'},
      {id: 5, name: 'Общая стоимость объекта по АИП'},
      {id: 6, name: 'Общая стоимость объекта по МГЭ'},
      {id: 7, name: 'Общая стоимость объекта по ПСС'},
      {id: 8, name: 'Срок ввода по контракту'},
      {id: 9, name: 'Срок ввода по плану'},
      {id: 10, name: 'Проектировщик'},
      {id: 11, name: 'Заказчик-застройщик'},
      {id: 12, name: 'Генподрядчик'},
    ]
  end


  def self.teps_values
    teps = []
    Obj.all.each do |o|
      teps.push({id: "#{1}_#{o.id}", object_id: o.id, option_id: 1, value: "#{o.power||'–'} #{o.power_measure||'–'}" })
      teps.push({id: "#{2}_#{o.id}", object_id: o.id, option_id: 2, value: "#{o.rooms_square||'–'}" })
      teps.push({id: "#{3}_#{o.id}", object_id: o.id, option_id: 3, value: "1-ком: #{o.count_1k||'–'} кв" })
      teps.push({id: "#{4}_#{o.id}", object_id: o.id, option_id: 3, value: "2-ком: #{o.count_2k||'–'} кв" })
      teps.push({id: "#{5}_#{o.id}", object_id: o.id, option_id: 3, value: "3-ком: #{o.count_3k||'–'} кв" })
      teps.push({id: "#{6}_#{o.id}", object_id: o.id, option_id: 3, value: "4-ком: #{o.count_4k||'–'} кв" })
      teps.push({id: "#{7}_#{o.id}", object_id: o.id, option_id: 4, value: "#{o.floors||'–'}" })
      teps.push({id: "#{8}_#{o.id}", object_id: o.id, option_id: 5, value: "#{o.budget||0}" })
      teps.push({id: "#{9}_#{o.id}", object_id: o.id, option_id: 6, value: "#{0}" })
      teps.push({id: "#{10}_#{o.id}", object_id: o.id, option_id: 7, value: "#{o.summ_PPS}" })
      teps.push({id: "#{11}_#{o.id}", object_id: o.id, option_id: 8, value: "#{o.getYearCorrect}" })
      teps.push({id: "#{12}_#{o.id}", object_id: o.id, option_id: 9, value: "#{o.year_plan}" })
      teps.push({id: "#{13}_#{o.id}", object_id: o.id, option_id: 10, value: "#{o.projector}" })
      teps.push({id: "#{14}_#{o.id}", object_id: o.id, option_id: 11, value: "#{o.techinikal_customer}" })
      teps.push({id: "#{15}_#{o.id}", object_id: o.id, option_id: 12, value: "#{o.general_builder}" })
    end
    teps
  end

  def self.documents_statuses
    documents = []
    Obj.includes(:object_document).all.each do |o|
      documents.concat(o.object_document.documents_status)
    end
    documents
  end

  def self.key_dates
    [{id:1, name: 'Выход подрядчика на строй площадку'},
     {id:2, name: 'Сети'},
     {id:3, name: 'Строительные работы'},
     {id:4, name: 'Отделка'}]
  end

  def self.key_dates_values
    dates = []
    Obj.includes(:object_document).all.each do |o|
      dates << {id: "#{1}_#{o.id}",  object_id: o.id, date: ObjectDocument.get_date_in_timestamps(o.object_document.builder_enter_fact)}
      dates << {id: "#{2}_#{o.id}",  object_id: o.id, date: ObjectDocument.get_date_in_timestamps(o.SMR_external_network)}
      dates << {id: "#{3}_#{o.id}",  object_id: o.id, date: ObjectDocument.get_date_in_timestamps(o.SMR_constructive)}
      dates << {id: "#{4}_#{o.id}",  object_id: o.id, date: ObjectDocument.get_date_in_timestamps(o.SMR_internal)}
    end
    dates
  end

  def self.additional_requirements
    [{id:1, name: 'Требуется ли отселение'},
     {id:2, name: 'Планируемая дата отселения'},
     {id:3, name: 'Фактическая дата отселения'},
     {id:4, name: 'Размер компенсации'},
     {id:5, name: 'Требуется ли снос'},
     {id:6, name: 'Планируемая дата сноса'},
     {id:7, name: 'Фактическая дата сноса'},
     {id:8, name: 'Размер компенсации'}]
  end

  def self.additional_requirements_values
    values = []
    Obj.all.each do |o|
      values<< {id: "#{1}_#{o.id}", requirement_id: 1, object_id: o.id, value: o.evacuation_status||'-'}
      values<< {id: "#{2}_#{o.id}", requirement_id: 2, object_id: o.id, value: o.evacuation_date_plan||'-'}
      values<< {id: "#{3}_#{o.id}", requirement_id: 3, object_id: o.id, value: o.evacuation_date||'-'}
      values<< {id: "#{4}_#{o.id}", requirement_id: 4, object_id: o.id, value: 'Неизвестно'}
      values<< {id: "#{5}_#{o.id}", requirement_id: 5, object_id: o.id, value: o.demolition_status||'-'}
      values<< {id: "#{6}_#{o.id}", requirement_id: 6, object_id: o.id, value: o.demolition_date_plan||'-'}
      values<< {id: "#{7}_#{o.id}", requirement_id: 7, object_id: o.id, value: o.demolition_date||'-'}
      values<< {id: "#{8}_#{o.id}", requirement_id: 8, object_id: o.id, value: 'Неизвестно'}
    end
    values
  end

  def self.object_works_groups
    [{id:1, name: 'ОСВОБОЖДЕНИЕ ПЛОЩАДКИ ОТ СЕТЕЙ'},
     {id:2, name: 'ПЕРЕКЛАДКА ИНЖЕНЕРНЫХ КОММУНИКАЦИЙ'},
     {id:3, name: 'ЭЛЕКТРОСНАБЖЕНИЕ'},
     {id:4, name: 'ТЕПЛОСНАБЖЕНИЕ'},
     {id:5, name: 'ВОДОСНАБЖЕНИЕ'},
     {id:6, name: 'КАНАЛИЗАЦИЯ'},
     {id:7, name: 'ВОДОСТОК'},
     {id:8, name: 'СЕТИ СВЯЗИ'}]
  end

  def self.object_works_names

    [
        {id:11, name: 'Соглашение о компенсации потерь заключено'},
        {id:12, name: 'Компенсация оплачена'},
        {id:13, name: 'Работы по выносу (ликвидации) выполнены'},
        {id:21, name: 'Соглашение о компенсации потерь заключено'},
        {id:22, name: 'Компенсация оплачена	'},
        {id:23, name: 'Работы по перекладке выполнены'},
        {id:31, name: 'Договор на технологическое присоединение'},
        {id:32, name: 'Строительство ТП, прокладка КЛ (%)'},
        {id:33, name: 'Акт технологического присоединения'},
        {id:34, name: 'Включение постоянного электроснабжения'},
        {id:41, name: 'Выдана согласованная РД'},
        {id:42, name: 'Строительство сетей (%)'},
        {id:43, name: 'Монтаж ИТП, ЦТП (%)'},
        {id:44, name: 'Подача тепла по временному договору'},
        {id:45, name: 'Постоянное теплоснабжение'},

        {id:51, name: 'Выдана согласованная РД'},
        {id:52, name: 'Прокладка сетей (%)'},
        {id:53, name: 'Акт технической приемки'},
        {id:61, name: 'Выдана согласованная РД'},
        {id:62, name: 'Прокладка сетей (%)'},
        {id:73, name: 'Акт технической приемки'},
        {id:71, name: 'Выдана согласованная РД'},
        {id:72, name: 'Прокладка сетей (%)'},
        {id:73, name: 'Акт технической приемки'},
        {id:81, name: 'Выдана согласованная РД'},
        {id:82, name: 'Прокладка сетей (%)'},
        {id:83, name: 'Акт технической приемки'},
    ]
  end

  def self.object_works_names_by_groups

    [
        {work_id:11, category_id: 1},
        {work_id:12, category_id: 1},
        {work_id:13, category_id: 1},
        {work_id:21, category_id: 2},
        {work_id:22, category_id: 2},
        {work_id:23, category_id: 2},
        {work_id:31, category_id: 3},
        {work_id:32, category_id: 3},
        {work_id:33, category_id: 3},
        {work_id:34, category_id: 3},
        {work_id:41, category_id: 4},
        {work_id:42, category_id: 4},
        {work_id:43, category_id: 4},
        {work_id:44, category_id: 4},
        {work_id:45, category_id: 4},

        {work_id:51, category_id: 5},
        {work_id:52, category_id: 5},
        {work_id:53, category_id: 5},
        {work_id:61, category_id: 6},
        {work_id:62, category_id: 6},
        {work_id:63, category_id: 6},
        {work_id:71, category_id: 7},
        {work_id:72, category_id: 7},
        {work_id:73, category_id: 7},
        {work_id:81, category_id: 8},
        {work_id:82, category_id: 8},
        {work_id:83, category_id: 8},
    ]
  end

  def self.object_works_values
    values = []
    Obj.includes(:object_prepare).all.each do |o|
      values<< {id: "#{11}_#{o.id}", work_id: 11, object_id: o.id, value: o.object_prepare.destroy_net_compensation_document||'-'}
      values<< {id: "#{12}_#{o.id}", work_id: 12, object_id: o.id, value: o.object_prepare.destroy_net_compensation_payed||'-'}
      values<< {id: "#{13}_#{o.id}", work_id: 13, object_id: o.id, value: o.object_prepare.destroy_net_work_complete||'-'}

      values<< {id: "#{21}_#{o.id}", work_id: 21, object_id: o.id, value: o.object_prepare.replace_engineer_compensation_document||'-'}
      values<< {id: "#{22}_#{o.id}", work_id: 22, object_id: o.id, value: o.object_prepare.replace_engineer_compensation_payed||'-'}
      values<< {id: "#{23}_#{o.id}", work_id: 23, object_id: o.id, value: o.object_prepare.replace_engineer_work_complete||'-'}

      values<< {id: "#{31}_#{o.id}", work_id: 31, object_id: o.id, value: o.object_prepare.electro_techo_dogovor||'-'}
      values<< {id: "#{32}_#{o.id}", work_id: 32, object_id: o.id, value: o.object_prepare.electro_build_percent||'-'}
      values<< {id: "#{33}_#{o.id}", work_id: 33, object_id: o.id, value: o.object_prepare.electro_techo_act||'-'}
      values<< {id: "#{34}_#{o.id}", work_id: 34, object_id: o.id, value: o.object_prepare.electro_techo_complete||'-'}

      values<< {id: "#{41}_#{o.id}", work_id: 41, object_id: o.id, value: o.object_prepare.warm_get_RD||'-'}
      values<< {id: "#{42}_#{o.id}", work_id: 42, object_id: o.id, value: o.object_prepare.warm_build_net_percent||'-'}
      values<< {id: "#{43}_#{o.id}", work_id: 43, object_id: o.id, value: o.object_prepare.warm_installation_ITP_percent||'-'}
      values<< {id: "#{44}_#{o.id}", work_id: 44, object_id: o.id, value: o.object_prepare.warm_temporary_document||'-'}
      values<< {id: "#{45}_#{o.id}", work_id: 45, object_id: o.id, value: o.object_prepare.warm_complete||'-'}

      values<< {id: "#{51}_#{o.id}", work_id: 51, object_id: o.id, value: o.object_prepare.water_get_RD||'-'}
      values<< {id: "#{52}_#{o.id}", work_id: 52, object_id: o.id, value: o.object_prepare.water_build_net_percent||'-'}
      values<< {id: "#{53}_#{o.id}", work_id: 53, object_id: o.id, value: o.object_prepare.water_act_get||'-'}

      values<< {id: "#{61}_#{o.id}", work_id: 61, object_id: o.id, value: o.object_prepare.sewage_get_RD||'-'}
      values<< {id: "#{62}_#{o.id}", work_id: 62, object_id: o.id, value: o.object_prepare.sewage_build_net_percent||'-'}
      values<< {id: "#{63}_#{o.id}", work_id: 63, object_id: o.id, value: o.object_prepare.sewage_act_get||'-'}

      values<< {id: "#{71}_#{o.id}", work_id: 71, object_id: o.id, value: o.object_prepare.drain_get_RD||'-'}
      values<< {id: "#{72}_#{o.id}", work_id: 72, object_id: o.id, value: o.object_prepare.drain_build_net_percent||'-'}
      values<< {id: "#{73}_#{o.id}", work_id: 73, object_id: o.id, value: o.object_prepare.drain_act_get||'-'}

      values<< {id: "#{81}_#{o.id}", work_id: 81, object_id: o.id, value: o.object_prepare.link_get_RD||'-'}
      values<< {id: "#{82}_#{o.id}", work_id: 82, object_id: o.id, value: o.object_prepare.link_build_net_percent||'-'}
      values<< {id: "#{83}_#{o.id}", work_id: 83, object_id: o.id, value: o.object_prepare.link_act_get||'-'}

    end
    values
  end


  def self.object_visit_dates
    dates = []
    VisitInfo.order(:object_id, :sort1, :sort2).all.each do |vi|
      dates << {object_id: vi.object_id, date: vi.max_data.to_time.to_i}
    end
    dates
  end

  def self.object_visit_perfomance_names
    names = []
    VisitInfo.order(:object_id, :sort1, :sort2).all.each do |vi|
      names << {id: vi.sort2, parent_id: 0, name:vi.parametr_name }
    end
    names
  end

  def self.object_visit_perfomance_values
    values = []
    VisitInfo.order(:object_id, :sort1, :sort2).all.each do |vi|
      values << {work_id: vi.sort2, object_id: vi.object_id, percent: vi.percent}
    end
    values
  end

  def self.object_tenders_list
    values = []
    ObjectTender.all.each do |t|
      values << {
          object_id: t.object_id,
          contractor_id: t.organization_id,
          type_id: t.type_new,
          status: t.status,
          date_start: t.date_start.nil? ? nil : t.date_start.to_time.to_i,
          date_finish: t.date_finish.nil? ? nil : t.date_finish.to_time.to_i,
          price_start: t.price_begin,
          price_finish: t.price_end,
          request_filed_count: t.bid_all,
          request_accepted_count: t.bid_accept
      }
    end
    values
  end


  def self.api_response
    {
        :objectType => Obj.objects_types_hierarchy,
        :objectRegion => Obj.objects_regions,
        :objects => Obj.all_objects_json,
        :landPassport => Obj.land_passports,
        :expertise => Obj.expertises,
        :buildingPermit => Obj.permits,
        :bankGuarantee => Obj.banking_garanty_statuses,
        :buildingDemolition => Obj.demolitions,
        :objectWorkPayment => Obj.objects_payment,
        :objectPerformance => Obj.object_perfomance,
        :objectBudget => Obj.objects_budjets,
        :optionName => Obj.teps_list,
        :optionValue => Obj.teps_values,
        :objectDocumentName => ObjectDocument.documents_name,
        :objectDocumentCategoryName => ObjectDocument.document_categories,
        :objectDocumentCategory => ObjectDocument.object_document_category,
        :objectDocument => Obj.documents_statuses,
        :objectProductionDateName => Obj.key_dates,
        :objectProductionDate => Obj.key_dates_values,
        :objectAdditionalRequirementName => Obj.additional_requirements,
        :objectAdditionalRequirement => Obj.additional_requirements_values,
        :objectEngineeringWorkCategory => Obj.object_works_names_by_groups,
        :objectEngineeringWorkName => Obj.object_works_names,
        :objectEngineeringWorkCategoryName => Obj.object_works_groups,
        :objectEngineeringWork => Obj.object_works_values,
        :objectVisitDate => Obj.object_visit_dates,
        :objectWorkPerformanceName => Obj.object_visit_perfomance_names,
        :objectWorkPerformance => Obj.object_visit_perfomance_values,
        :auction => Obj.object_tenders_list,
        :auctionType => ObjectTender.tender_types
    }
  end

end
