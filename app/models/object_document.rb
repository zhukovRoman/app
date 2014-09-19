class ObjectDocument < ActiveRecord::Base
  ObjectDocument.establish_connection :mssqlObjects

  self.table_name = "vw_ObjectForMobileInfoDocuments"
  self.primary_key = "ObjectId"

  has_one :obj, foreign_key: "ObjectId"

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
  alias_attribute "BI_fact","DataDogovorProjector"
  alias_attribute "BI_plan","DataPlanDogovorProjector"
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
    #puts self.id
    #puts fact
    #puts plan
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

end