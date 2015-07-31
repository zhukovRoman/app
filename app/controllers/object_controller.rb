class ObjectController < ApplicationController
  #before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Объекты"
  end

  def index
    #authorize! :index, self
    require 'json'
    @objects = Obj.notArchive
    @data = Hash.new
    @data['objects']=Array.new
    objects = @data['objects']
    @objects.each do |o|
      object = Hash.new
      object['okrug']=o.region
      object['GPZU'] = o.getGPZUStatus
      object['year'] = o.getYearCorrect.to_s
      object['MGE']=o.getMGEStatus.to_s
      object['razresh']=o.getRazreshStatus.to_s
      object['bank_garant']=o.getBankGarantStatus.to_s
      object['destroy']=o.getDestroyStatus.to_s
      plansdate = Hash.new
      plansdate['GPZU']=o.object_document.GPZU_plan.to_s
      plansdate['MGE']=o.object_document.MGE_plan.to_s
      plansdate['razresh']=o.object_document.razrezh_build_plan.to_s
      plansdate['bank_garant']=Date.current.to_s
      plansdate['destroy']=(o.demolition_date_plan||Date.current).strftime('%d.%m.%Y')
      object['plansDates']=plansdate
      object['appointment']=o.appointment

      object['payed']=o.object_finance.payed_without_avans #
      object['payed_left']=o.object_finance.payed_left#
      object['avans_pogasheno']=o.object_finance.avans_pogasheno #
      object['avans_ne_pogasheno']=o.object_finance.avans_ne_pogasheno #

      object['work_left']=o.object_finance.work_left
      object['work_complete']=o.object_finance.complete_work||0
      object['lat']=o.lat
      object['lng']=o.lng
      object['id']=o.id
      object['adress']=o.adress
      object['power']=o.power
      object['power_measure']=o.power_measure
      object['year_plan']=object['year']
      object['AIP']=o.object_finance.sumAIP
      object['manager']=o.manager

      objects.push(object)
    end
    @districts = Obj.getAllDistricts
    @years = Obj.getAllEnterYears
    @appointments = Obj.getAllAppointmentType


    puts @objects.to_json.html_safe
    puts @years.to_json.html_safe
    puts @appointments.to_json.html_safe
    puts @districts.to_json.html_safe
    puts @data.to_json.html_safe

    render "index3"
  end

  def finance
    authorize! :index, self
  end

  def organizations
    #authorize! :index, self
    require 'json'

    allTendersByYears = Hash.new
    ObjectTender.where(status: 'проведен').
        group("YEAR(DataFinish)").distinct('ObjectID').count.each do |year, countT|

      allTendersByYears[year]=allTendersByYears[year]||Hash.new
      allTendersByYears[year]['count']=countT
    end

    ObjectTender.where(status: 'проведен').
        group("YEAR(DataFinish)").sum('TenderPriceEnd').each do |year, summT|

      allTendersByYears[year]=allTendersByYears[year]||Hash.new
      allTendersByYears[year]['sum']=summT
    end



    @organizations = Array.new
    #temp = Organization.includes(:objs)
    Organization.includes(:objs, :object_tenders, objs: :object_finance).where(vw_ObjectForMobileInfo_NEW: {ObjectArchve: 0}).each do |org|
      if (org.objs.count==0)
        next
      end
      temporary_obj = Hash.new
      temporary_obj['name']=org.name
      temporary_obj['id']=org.id
      temporary_obj['payed_left']=(org.residue_summ_for_all_objects).round
      temporary_obj['payed']=(org.payed_for_work_for_all_objects).round
      temporary_obj['avans_pogasheno']=(org.avans_pagasheno_for_all_objects).round
      temporary_obj['avans_ne_pogasheno']=(org.avans_not_pagasheno_for_all_objects).round
      temporary_obj['work_complete']=(org.work_complete_summ_for_all_objects).round
      temporary_obj['work_left']=(org.work_left_summ_for_all_objects).round
      temporary_obj['phone']='Недоступно'
      temporary_obj['email']='Недоступно'
      temporary_obj['FIO'] = 'Недоступно'
      temporary_obj['address'] = 'Недоступно'

      #parts in tenders
      temporary_obj['tenders_parts'] = Hash.new
      temporary_obj['tenders_parts']['all']=allTendersByYears
      temporary_obj['tenders_parts']['current'] = org.getOrgPartsInTendersByYears
      org_objects = Array.new
      org.objs.each do |o|
        obj = Hash.new
        obj['id']=o.id
        obj['name']=(o.name||'')[0,200]
        obj['address']=(o.adress||'')[0,200]
        obj['status']=o.status_name||'-'
        obj['region']=o.region
        obj['year']=o.getYearCorrect
        obj['network']=o.SMR_external_network||'-'
        obj['network_delay']=o.SMR_external_network_delay||0
        obj['constructive']=o.SMR_constructive||'-'
        obj['constructive_delay']=o.SMR_constructive_delay||0
        obj['internal']=o.SMR_internal||'-'
        obj['internal_delay']=o.SMR_internal_delay||0
        finance = o.get_object_finance_by_type(1).take
        obj['contract_sum']=finance == nil ? 0 : (finance.work_summ||0).round
        org_objects.push(obj)
      end
      temporary_obj['objects']=org_objects
      temporary_obj['tenders']=org.get_tenders
      @organizations.push(temporary_obj)
    end

    puts @organizations.to_json.html_safe
  end

  def view
    id = params['id']
    if id == nil
      raise ActionController::RoutingError.new('Not Found')
    end

    @object = Obj.find_by id: id
    if @object == nil
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def self.getJSONData
    objs = Hash.new
    Obj.notArchive.each do |o|
      tmp = Hash.new
      tmp['id'] = o.id
      tmp['address'] = o.adress
      tmp['region'] = o.region
      tmp['lat'] = o.lat
      tmp['lng'] = o.lng
      tmp['power_plus_measure'] = "#{(o.power!=nil ? o.power.round : "Неизвестно")} #{(o.power_measure!=nil ? o.power_measure : "")}"
      tmp['power'] = (o.power!=nil ? o.power.round : "Неизвестно")
      tmp['power_measure'] = (o.power_measure!=nil ? o.power_measure : "")
      tmp['appointment'] = o.appointment
      tmp['living_square'] = "Неизвестно"
      tmp['rooms'] = "1-ком: #{o.Q1Rooms!=nil ? o.Q1Rooms.round : "-"} кв<br>".html_safe+
                        "2-ком: #{o.Q2Rooms!=nil ? o.Q2Rooms.round : "-"} кв<br>".html_safe+
                        "3-ком: #{o.Q3Rooms!=nil ? o.Q3Rooms.round : "-"} кв<br>".html_safe+
                        "4-ком: #{o.Q4Rooms!=nil ? o.Q4Rooms.round : "-"} кв".html_safe

      tmp['floors'] = o.floors||'-'
      tmp['amount_AIP'] = o.budget
      tmp['amount_MGE'] = 0
      tmp['amount_PSS'] = o.SumPSS
      tmp['year_correct'] = o.getYearCorrect
      tmp['year_plan'] = o.year_plan
      tmp['projector'] = o.projector
      tmp['techinikal_customer'] =o.techinikal_customer
      tmp['general_builder'] = o.general_builder
      smr_work = o.get_object_finance_by_type(1).take
      if(smr_work != nil)
        tmp['work_summ'] = smr_work.work_summ||0
        tmp['smr_title'] = (smr_work.organization_name||'') +
            ' по договору '+ (smr_work.document_number||'')
        tmp['smr_amount'] = (smr_work.work_summ||0).round
        tmp['payed_for_work'] = (smr_work.payed_for_work||0).round
        tmp['avans_pogasheno'] = (smr_work.avans_pogasheno||0).round
        tmp['avans_not_pogasheno'] =   (smr_work.in_avance_work||0).round
        tmp['payed_left'] = (smr_work.pay_left||0).round

        tmp['work_complite'] = smr_work.work_comlete||0
        tmp['work_left'] = smr_work.work_left||0
      end

      tmp['budjet_payed']= o.object_finance.pay_current_year
      tmp['limit_residue'] = o.object_finance.limit_residue


      #Документы
      tmp['GPZU'] = [(o.object_document.GPZU_plan||'-'),(o.object_document.GPZU_fact||'Не получено')]
      tmp['BSP'] = [(o.object_document.BSP_plan||'-'),(o.object_document.BSP_fact||'Не получено')]
      tmp['tz_tnz'] = [(o.object_document.BSP_plan||'-'),(o.object_document.BSP_fact||'Не получено')]
      tmp['tech_join'] = ['Нет данных','']

      tmp['project_contract'] = [(o.object_document.project_dogovor_plan||'-'),(o.object_document.project_dogovor_fact||'Не получено')]
      tmp['POS']= [(o.object_document.POS_plan||'-'),(o.object_document.POS_fact||'Не получено')]
      tmp['ARG']= [(o.object_document.AGR_plan||'-'),(o.object_document.AGR_fact||'Не получено')]
      tmp['MGE']= [(o.object_document.MGE_plan||'-'),(o.object_document.MGE_fact||'Не получено')]
      tmp['PSD']= [(o.object_document.PSD_plan||'-'),(o.object_document.PSD_fact||'Не получено')]

      tmp['genbuilder_contract']= [(o.object_document.dogovor_genbuilder_plan||'-'),(o.object_document.dogovor_genbuilder_fact||'Не получено')]
      tmp['build_access']= [(o.object_document.razrezh_build_plan||'-'),(o.object_document.razrezh_build_fact||'Не получено')]
      tmp['net_plan']= [(o.object_document.network_plan_plan||'-'),(o.object_document.network_plan_fact||'Не получено')]
      tmp['build_end']= [(o.object_document.izvesg_end_build_plan||'-'),(o.object_document.izvesh_end_build_fact||'Не получено')]

      tmp['BTI_sparvka']= [(o.object_document.spravka_BTI_plan||'-'),(o.object_document.spravka_BTI_fact||'Не получено')]
      tmp['ZOS']= ['Нет данных','Нет данных']
      tmp['razresh_enter']= [(o.object_document.razreshenie_enter_plan||'-'),(o.object_document.razreshenie_enter_fact||'Не получено')]
      tmp['BI_act']= [(o.object_document.act_BI_plan||'-'),(o.object_document.act_BI_fact||'Не получено')]

      tmp['gen_builder_start']=(o.object_document.builder_enter_fact||'Не вышел')

      #tmp['tnz'] = 'Нет данных'
      #tmp['tz'] = 'Нет данных'
      #tmp['stuff_list'] = 'Нет данных'
      #tmp['build_access'] = o.object_document.razrezh_build_fact||'Не получено'
      #tmp['project_task'] = 'Нет данных'
      ##tmp['BSP'] = o.object_document.BSP_fact||'Не получено'
      #tmp['razresh_enter'] = o.object_document.razreshenie_enter_fact||'Не получено'
      #tmp['ZOS'] = 'Нет данных'
      #tmp['step_p'] = 'Нет данных'
      #tmp['step_RD'] = 'Нет данных'
      #tmp['tech_conditionals'] = 'Нет данных'
      #tmp['tech_join'] = 'Нет данных'

      #снос и отселение
      tmp['evacuation_status'] = o.evacuation_status||'-'
      tmp['evacuation_plan'] = o.evacuation_date_plan||'-'
      tmp['evacuation_fact'] = o.evacuation_date||'-'
      tmp['evacuation_cost'] = 'Нет данных'

      tmp['demolition_status'] = o.demolition_status||'-'
      tmp['demolition_plan'] = o.demolition_date_plan||'-'
      tmp['demolition_fact'] = o.demolition_date||'-'
      tmp['demolition_cost'] = 'Нет данных'

      tmp['SMR_network'] = (o.SMR_external_network||'-')+' '+(o.SMR_external_network_delay||'')
      tmp['SMR_external'] = (o.SMR_constructive||'-')+' '+(o.SMR_constructive_delay||'')
      tmp['SMR_internal'] = (o.SMR_internal||'-')+' '+(o.SMR_internal_delay||'')

      tmp['destroy_document'] = o.object_prepare.destroy_net_compensation_document||'-'
      tmp['destroy_payed'] = o.object_prepare.destroy_net_compensation_payed||'-'
      tmp['destroy_work_complete'] = o.object_prepare.destroy_net_work_complete||'-'

      tmp['compensation_document'] = o.object_prepare.replace_engineer_compensation_document||'-'
      tmp['compensation_payed'] = o.object_prepare.replace_engineer_compensation_payed||'-'
      tmp['compensation_work_complete'] = o.object_prepare.replace_engineer_work_complete||'-'

      tmp['electro_document'] = o.object_prepare.electro_techo_dogovor||'-'
      tmp['electro_build_percent'] = o.object_prepare.electro_build_percent||'-'
      tmp['electro_techo_act'] = o.object_prepare.electro_techo_act||'-'
      tmp['electro_complete'] = o.object_prepare.electro_techo_complete||'-'

      tmp['warm_RD'] = o.object_prepare.warm_get_RD||'-'
      tmp['warm_build_percent'] = o.object_prepare.warm_build_net_percent||'-'
      tmp['warm_installation_percent'] = o.object_prepare.warm_installation_ITP_percent||'-'
      tmp['warm_temp_auto'] = o.object_prepare.warm_temporary_document||'-'
      tmp['warm_complete'] = o.object_prepare.warm_complete||'-'

      tmp['water_RD'] = o.object_prepare.water_get_RD||'-'
      tmp['water_percent'] = o.object_prepare.water_build_net_percent||'-'
      tmp['water_act'] = o.object_prepare.water_act_get||'-'

      tmp['sewage_RD'] = o.object_prepare.sewage_get_RD||'-'
      tmp['sewage_percent'] = o.object_prepare.sewage_build_net_percent||'-'
      tmp['sewage_act'] = o.object_prepare.sewage_act_get||'-'

      tmp['drain_RD'] = o.object_prepare.drain_get_RD||'-'
      tmp['drain_percent'] = o.object_prepare.drain_build_net_percent||'-'
      tmp['drain_act'] = o.object_prepare.drain_act_get||'-'

      tmp['link_RD'] = o.object_prepare.link_get_RD||'-'
      tmp['link_percent'] = o.object_prepare.link_build_net_percent||'-'
      tmp['link_act'] = o.object_prepare.link_act_get||'-'

      tmp['tenders'] = Array.new
      o.tenders.each do |t|
        tender = Hash.new
        tender['type'] = t.type
        tender['status'] = t.status
        tender['date_start'] = ObjectTender.frendly_date (t.date_start)
        tender['date_end'] = ObjectTender.frendly_date (t.date_finish)
        tender['price_begin'] = t.price_begin;
        tender['price_end']=t.price_end;
        tender['percent'] = (t.percent_decline||0).round 2
        tender['bid_all'] = t.bid_all
        tender['bid_accept'] = t.bid_accept
        tmp['tenders'].push tender
      end

      tmp['visit_info'] = Hash.new

      o.getVisitsInfo.each do |vi|
        tmp['visit_date'] = vi.visit_date
        tmp['visit_info'][vi.get_parametr_name] = vi.percent
      end


      objs[o.id] = tmp;
    end

    #logger = Logger.new("#{Rails.root}/log/object_detail.js")
    #logger.warn("var objects_detail="+objs.to_json.html_safe)

    return objs;
  end

  def overdue
    @objects = Obj.overdueObjects
  end

end
