class ObjectDocument < ActiveRecord::Base
  ObjectDocument.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfoDocuments"
  self.primary_key = "ObjectId"

  has_one :obj, foreign_key: "ObjectId"

  alias_attribute "object_id","ObjectId"
  #Предпроект
  alias_attribute "GPZU_plan","DataPlanGPZU"
  alias_attribute "GPZU_fact","DataGPZU"
  alias_attribute "peredacha_fact","DataPeredachaKP"
  alias_attribute "peredacha_plan","DataPlanPeredachaKP"
  alias_attribute "BI_fact","DataBI"
  alias_attribute "BI_plan","DataPlanBI"
  alias_attribute "BSP_fact","DataBSP"
  alias_attribute "BSP_plan","DataPlanBSP"
  alias_attribute "TZ_comm_fact","DataKomissiya"
  alias_attribute "TZ_comm_plan","DataPlanKomissiya"

  #Проектирование
  alias_attribute "project_dogovor_fact","DataDogovorProjector"
  alias_attribute "project_dogovor_plan","DataPlanDogovorProjector"
  alias_attribute "titul_RIP","Titul_PIR"
  alias_attribute "POS_fact","DataPOS"
  alias_attribute "POS_plan","DataPlanPOS"
  alias_attribute "AGR_fact","DataAGR"
  alias_attribute "AGR_plan","DataPlanAGR"
  alias_attribute "MGE_fact","DataMGE"
  alias_attribute "MGE_plan","DataPlanMGE"
  alias_attribute "PSD_fact","DataPSD"
  alias_attribute "PSD_plan","DataPlanPSD"

  #Строительство
  alias_attribute "builder_enter_fact","ObjectDataEnter"
  alias_attribute "builder_enter_plan","ObjectDataPlanEnter"
  alias_attribute "dogovor_genbuilder_fact","DataDogovorGenBuilder"
  alias_attribute "dogovor_genbuilder_plan","DataPlanDogovorGenBuilder"
  alias_attribute "titul_SMR","Titul_SMR"
  alias_attribute "razrezh_build_fact","DataRazreshStr"
  alias_attribute "razrezh_build_plan","DataPlanRazreshStr"
  alias_attribute "network_plan_fact","DataPlanNetwork"
  alias_attribute "network_plan_plan","DataPlanPlanNetwork"
  alias_attribute "izvesh_end_build_fact","DataIzveshEndBuilding"
  alias_attribute "izvesg_end_build_plan","DataPlanIzveshEndBuilding"

  #Ввод и передача на баланс
  alias_attribute "zayavka_TBTI_fact","DataZ_TBTI"
  alias_attribute "zayavka_TBTI_plan","DataPlanZ_TBTI"
  alias_attribute "spravka_BTI_fact","DataAdressBTI"
  alias_attribute "spravka_BTI_plan","DataPlanAdressBTI"
  alias_attribute "razreshenie_enter_fact","DataRazreshVvod"
  alias_attribute "razreshenie_enter_plan","DataPlanRazreshVvod"
  alias_attribute "act_BI_fact","DataAktRealizBI"
  alias_attribute "act_BI_plan","DataPlanAktRealizBI"


  def getGPZUStatus
    plan = self.GPZU_plan
    fact = self.GPZU_fact
    if (plan==nil && fact==nil) || (plan != nil && fact==nil && Date.parse(plan) >= Date.current)
      return "Без ГПЗУ"
    end
    if (plan==nil && Date.parse(fact) < Date.current) ||
        (plan!=nil && fact!=nil && Date.parse(plan)>=Date.parse(fact))
      return "Получено"
    end
    if (plan!=nil && fact!=nil && Date.parse(plan)<Date.parse(fact))
      return "Получено с опозданием"
    end
    if (plan!=nil && Date.parse(plan) < Date.current && fact==nil)
      return "Просрочено"
    end
  end

  def getMGEStatus
    plan = self.MGE_plan
    fact = self.MGE_fact
    if (plan==nil && fact==nil) || (plan != nil && fact==nil && Date.parse(plan) >= Date.current)
      return "Без экспертизы"
    end
    if (plan==nil && Date.parse(fact) < Date.current) ||
        (plan!=nil && fact!=nil && Date.parse(plan)>=Date.parse(fact))
      return "Получено"
    end
    if (plan!=nil && fact!=nil && Date.parse(plan)<Date.parse(fact))
      return "Получено с опозданием"
    end
    if (plan!=nil && Date.parse(plan) < Date.current && fact==nil)
      return "Просрочено"
    end
    puts self.id
    puts fact
    puts plan
  end

  def getRazreshStatus
    plan = self.razrezh_build_plan
    fact = self.razrezh_build_fact
    if (plan==nil && fact==nil) || (plan != nil && fact==nil && Date.parse(plan) >= Date.current)
      return "Без разрешения"
    end
    if (plan==nil && Date.parse(fact) < Date.current) ||
        (plan!=nil && fact!=nil && Date.parse(plan)>=Date.parse(fact))
      return "Получено"
    end
    if (plan!=nil && fact!=nil && Date.parse(plan)<Date.parse(fact))
      return "Получено с опозданием"
    end
    if (plan!=nil && Date.parse(plan) < Date.current && fact==nil)
      return "Просрочено"
    end
    puts self.id
    puts fact
    puts plan
  end

  def self.documents_name
    [
        {id: 1, name: 'ГПЗУ'},
        {id: 2, name: 'Заключение МГЭ'},
        {id: 11, name: 'БСП'},
        {id: 4, name: 'Решение коммиссии по техническим и технологическим заданиям'},
        {id: 5, name: 'Договоры тех. присоединений'},
        {id: 6, name: 'Договор на проектирование'},
        {id: 7, name: 'ПОС'},
        {id: 8, name: 'АРГ'},
        {id: 9, name: 'Утвреждени ПСД'},
        {id: 10, name: 'Договор с генподрядчиком'},
        {id: 3, name: 'Разрешение на строительство'},
        {id: 12, name: 'План сетей'},
        {id: 13, name: 'Извещение об окончании строительства'},
        {id: 14, name: 'Справка БТИ об адресе'},
        {id: 15, name: 'ЗОС'},
        {id: 16, name: 'Разрешения на ввод'},
        {id: 17, name: 'Акт о реализации БИ'},
    ]
  end

  def self.document_categories
    [
        {id: 1, name: 'Предпроект'} ,
        {id: 2, name: 'Проектирование'},
        {id: 3, name: 'Строительство'},
        {id: 4, name: 'Ввод и передача на баланс'}
    ]
  end

  def self.object_document_category
    [
        {id: 1, type_id: 1, category_id: 1 },
        {id: 3, type_id: 11, category_id: 1 },
        {id: 4, type_id: 4, category_id: 1 },
        {id: 5, type_id: 5, category_id: 1 },

        {id: 6, type_id: 6, category_id: 2 },
        {id: 2, type_id: 2, category_id: 2 },
        {id: 7, type_id: 7, category_id: 2 },
        {id: 8, type_id: 8, category_id: 2 },
        {id: 9, type_id: 9, category_id: 2 },

        {id: 10, type_id: 10, category_id: 3 },
        {id: 11, type_id: 3, category_id: 3 },
        {id: 12, type_id: 12, category_id: 3 },
        {id: 13, type_id: 13, category_id: 3 },

        {id: 14, type_id: 14, category_id: 4 },
        {id: 15, type_id: 15, category_id: 4 },
        {id: 16, type_id: 16, category_id: 4 },
        {id: 17, type_id: 17, category_id: 4 },

    ]
  end
  
  def self.get_date_in_timestamps date
    date.nil? ? nil : date.to_time.to_i
  end

  def documents_status
    [
        { id: "#{1}_#{object_id}", object_id: object_id, type_id: 1, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.GPZU_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.GPZU_fact)},
        { id: "#{2}_#{object_id}",object_id: object_id, type_id: 2, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.MGE_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.MGE_fact)},
        { id: "#{11}_#{object_id}",object_id: object_id, type_id: 11, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.BSP_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.BSP_fact)},
        { id: "#{4}_#{object_id}",object_id: object_id, type_id: 4, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.TZ_comm_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.TZ_comm_fact)},
        { id: "#{5}_#{object_id}",object_id: object_id, type_id: 5, expected_receive_date: nil, real_receive_date: nil},
        { id: "#{6}_#{object_id}",object_id: object_id, type_id: 6, expected_receive_date: ObjectDocument.get_date_in_timestamps(project_dogovor_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(project_dogovor_fact)},
        { id: "#{7}_#{object_id}",object_id: object_id, type_id: 7, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.POS_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.POS_fact)},
        { id: "#{8}_#{object_id}",object_id: object_id, type_id: 8, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.AGR_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.AGR_fact)},
        { id: "#{9}_#{object_id}",object_id: object_id, type_id: 9, expected_receive_date: ObjectDocument.get_date_in_timestamps(self.PSD_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(self.PSD_fact)},
        { id: "#{10}_#{object_id}",object_id: object_id, type_id: 10, expected_receive_date: ObjectDocument.get_date_in_timestamps(dogovor_genbuilder_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(dogovor_genbuilder_fact)},
        { id: "#{3}_#{object_id}",object_id: object_id, type_id: 3, expected_receive_date: ObjectDocument.get_date_in_timestamps(razrezh_build_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(razrezh_build_fact)},
        { id: "#{12}_#{object_id}",object_id: object_id, type_id: 12, expected_receive_date: ObjectDocument.get_date_in_timestamps(network_plan_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(network_plan_fact)},
        { id: "#{13}_#{object_id}",object_id: object_id, type_id: 13, expected_receive_date: ObjectDocument.get_date_in_timestamps(izvesg_end_build_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(izvesh_end_build_fact)},
        { id: "#{14}_#{object_id}",object_id: object_id, type_id: 14, expected_receive_date: ObjectDocument.get_date_in_timestamps(spravka_BTI_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(spravka_BTI_fact)},
        { id: "#{15}_#{object_id}",object_id: object_id, type_id: 15, expected_receive_date: nil, real_receive_date: nil},
        { id: "#{16}_#{object_id}",object_id: object_id, type_id: 16, expected_receive_date: ObjectDocument.get_date_in_timestamps(razreshenie_enter_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(razreshenie_enter_fact)},
        { id: "#{17}_#{object_id}",object_id: object_id, type_id: 17, expected_receive_date: ObjectDocument.get_date_in_timestamps(act_BI_plan), real_receive_date: ObjectDocument.get_date_in_timestamps(act_BI_fact)}
    ]
  end

end