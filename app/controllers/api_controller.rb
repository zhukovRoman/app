class ApiController < ApplicationController
  before_action 'checkID'
  protect_from_forgery :except => [:employee, :tenders, :apartments, :objects, :organizations]
  #xhr :get, :employee, format: :js

  def checkID
    key = params['key']
  end
  def getchart
    string = render_to_string('/employee/charts/_employee_common_scripts.js')
    render :json => string
  end

  def employee
    @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    @plotXAxis = Array.new
    @plotDataSalary = Array.new
    @plotDataBonus = Array.new
    @plotDataTax = Array.new
    @plotDataAvgSalary = Array.new

    @plotDataEmployeeCount = Array.new
    @plotDataEmployeeDismiss = Array.new
    @plotDataEmployeeAdd = Array.new
    @plotDataVacancyCount = Array.new

    @plotDatakTek = Array.new
    @plotDatakNeuk = Array.new

    @plotDataManageCount = Array.new
    @plotDataProdCount = Array.new

    @plotDataManageSalary = Array.new
    @plotDataManageTax = Array.new
    @plotDataManageBonus = Array.new
    @plotDataManageAvg = Array.new
    @plotDataAUPCount = Array.new

    EmployeeStatsMonths.where(month: Date.current-1.year..Date.current).each do |stat|
      #@plotXAxis.push(stat.month.strftime('%b'))
      @plotXAxis.push(@standalone_month_names[stat.month.month])
      @plotDataSalary.push(stat.salary.round 0)
      @plotDataBonus.push(stat.bonus.round 0)
      @plotDataTax.push(stat.tax.round 0)
      @plotDataAvgSalary.push((stat.avg_salary.round 0))

      @plotDataEmployeeAdd.push(stat.employee_adds)
      @plotDataEmployeeCount.push(stat.employee_count)
      @plotDataEmployeeDismiss.push(stat.employee_dismiss)
      @plotDataVacancyCount.push(stat.vacancy_count)

      @plotDatakNeuk.push(((stat.k_complect*100).round 2))
      @plotDatakTek.push(((stat.k_dismiss*100).round 2))

      @plotDataManageCount.push((stat.employee_manage_count.to_f/1).round 1)
      @plotDataProdCount.push((stat.employee_production_count.to_f/1).round 1)

      @plotDataManageBonus.push(stat.bonus_manage.round 0)
      @plotDataManageSalary.push(stat.salary_manage.round 0)
      @plotDataManageTax.push(stat.tax_manage.round 0)
      @plotDataManageAvg.push(((stat.salary_manage/stat.AUP_count).round 0))
      @plotDataAUPCount.push(stat.AUP_count)
    end

    #departments stats
    @plotXAxisDep = Array.new
    @plotDataDepEmployeeStats = Hash.new
    @plotDataDepEmployeeStats['vacancy'] = (Array.new)
    @plotDataDepEmployeeStats['employee_count'] = (Array.new)

    #if(EmployeeStatsDepartments.where(month: (Date.current).at_beginning_of_month..(Date.current).at_end_of_month).count == 0)
    #  #EmployeeStatsDepartments.fillCurrentMonth()
    #end


    interval = (Date.current-1.month).at_beginning_of_month..(Date.current-1.month).at_end_of_month;
    if (Date.current.day<8 || EmployeeStatsDepartments.where(month: interval).count==0)
      interval = (Date.current-2.month).at_beginning_of_month..(Date.current-2.month).at_end_of_month;
    end


    EmployeeStatsDepartments.where(month: interval).each do |s|
      dep = Department.find(s.department_id)
      @plotXAxisDep.push(dep.name)

      info2 = Hash.new
      info2['y']=s.employee_count
      info2['manager']=s.manager
      @plotDataDepEmployeeStats['employee_count'].push(info2)

      info = Hash.new
      info['y']=s.vacancy_count
      info['manager']=s.manager
      @plotDataDepEmployeeStats['vacancy'].push(info)
    end
    @drilldownData = EmployeeStatsDepartments.get_data_for_drilldown
    @departmentsEmployeesMonthsCounts = EmployeeStatsDepartments.getMonthsEmployeesCounts

    @standalone_month_names = ["", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"];
    res = '';
    res += "xaxis: "+@plotXAxis.to_json.html_safe
    res += ",salary :"+@plotDataSalary.to_json.html_safe
    res += ",bonus :"+@plotDataBonus.to_json.html_safe
    res += ",tax : "+@plotDataTax.to_json.html_safe
    res += ",avg_salary : "+@plotDataAvgSalary.to_json.html_safe

    res += ",empl_counts : "+@plotDataEmployeeCount.to_json.html_safe
    res += ",empl_dismiss : "+@plotDataEmployeeDismiss.to_json.html_safe
    res += ",empl_add : "+@plotDataEmployeeAdd.to_json.html_safe
    res += ",vacancy_counts : "+@plotDataVacancyCount.to_json.html_safe

    res += ",k_tek : "+@plotDatakTek.to_json.html_safe
    res += ",k_neuk : "+@plotDatakNeuk.to_json.html_safe

    res += ",mamnger_counts : "+@plotDataManageCount.to_json.html_safe
    res += ",prod_counts : "+@plotDataProdCount.to_json.html_safe

    res += ",manager_salary : "+@plotDataManageSalary.to_json.html_safe
    res += ",manager_tax : "+@plotDataManageTax.to_json.html_safe
    res += ",manager_bonus : "+@plotDataManageBonus.to_json.html_safe
    res += ",manager_avg_salary : "+@plotDataManageAvg.to_json.html_safe
    res += ",aup_counts : "+@plotDataAUPCount.to_json.html_safe

    res += ",departments : "+@plotXAxisDep.to_json.html_safe
    res += ",deps_infos : "+@plotDataDepEmployeeStats.to_json.html_safe

    res += ",drilldown_data : "+@drilldownData.to_json.html_safe
    res += ",months_empl_count : "+@departmentsEmployeesMonthsCounts.to_json.html_safe



    response=params['callback']+'({'
    response+= res
    response += '})'

    render :js => response

  end

  def apartments
    data = ''
    file = File.new("test.json", "r")
    while (line = file.gets)
      data += line
    end
    file.close
    require 'json'
    data = JSON.parse(data)

    finish = Hash.new;
    notFinish = Hash.new;

    rooms = Hash.new

    @apartmetns = Array.new
    @objects = Array.new
    data['GetBuildingGroupsResult']['buildinggroups'].each do |obj|
      @objects.push obj['name']
      obj['buildings'].each do |build|
        build['sections'].each do |sec|
          sec['apartments'].each do |apart|
            if apart['status']=='Другое'
              next
            end
            a = Hash.new
            a['id']=apart['id']
            a['object']=obj['name']
            a['floor']=apart['floor']
            a['max_floor']=sec['floors']
            a['rooms']=apart['rooms']
            a['square']=apart['spaceDesign']
            #a['price_m2_start']=apart['cost']
            #a['price_m2_end']=apart['dpCost']
            a['price_m2_start']=(apart['sum']||0)/(apart['spaceDesign']||1)
            a['price_m2_contract']=(apart['orderSum']||(apart['sum']||0))/(apart['spaceDesign']||1)
            a['price_m2_end']=(apart['dpSum']||0)/(apart['spaceDesign']||1)
            a['free_date']=apart['apIsFreeDate']
            a['has_qty_date']=apart['apHasDemandDate']
            a['in_sing_date']=apart['apInSignDate']
            a['auction_date']=apart['auctionDateTime']
            a['sale_plan_date']=apart['salesOrderPlanDate']
            a['dkp_date']=apart['salesOrderDate']
            a['ps_date']=apart['ownCertificateDateOfIssue']
            a['sum']=apart['sum']
            a['order_sum']=apart['orderSum']||apart['sum']
            a['end_sum']=apart['dpSum']
            a['hypotec']=apart['isHypothec']
            a['bankName'] = apart['hypothecBankid']||'Личные средства'
            a['finishing']=apart['finishingLevel']
            a['fee']=apart['brokersFeeWithNDS']
            a['status']=apart['status']
            @apartmetns.push(a)
          end
        end
      end
    end
    @objects.sort

    res = ''
    res += 'apratmets_objects:'+@objects.to_json.html_safe
    res += ',apartments:'+@apartmetns.to_json.html_safe

    response=params['callback']+'({'
    response+= res
    response += '})'

    render :js => response

  end

  def objects
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

    res = '';
    res += 'objects:'+@objects.to_json.html_safe
    res += ',objects_year-enter:'+@years.to_json.html_safe
    res += ',objects_appointments:'+@appointments.to_json.html_safe
    res += ',objects_districs:'+@districts.to_json.html_safe
    res += ',objects_data:'+@data.to_json.html_safe
    res += ',objects_detaile_info:'+ObjectController.getJSONData.to_json.html_safe

    response=(params['callback']||'')+'({'
    response+= res
    response += '})'

    render :js => response

  end

  def organizations
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


    response=params['callback']+'({'
    response+= 'organizations:'+@organizations.to_json.html_safe
    response += '})'

    render :js => response
  end

  def tenders
    require 'json'

    @result = Hash.new
    years = Array.new
    @result['prices_begin']=Hash.new
    @result['prices_end']=Hash.new
    @result['prices_percent']=Hash.new
    @result['one_end']=Hash.new
    @result['one_start']=Hash.new
    @result['count']=Hash.new

    ObjectTender.all.each do |t|
      date = Date.parse(t.date_start.to_s)
      if (!years.include? date.year)
        years.push(date.year)
      end
      @result['count'][date.year] = (@result['count'][date.year]||0) + 1
      @result['prices_begin'][date.year] = (@result['prices_begin'][date.year]||0) + (t.price_begin||0)
      @result['prices_end'][date.year] = (@result['prices_end'][date.year]||0) + (t.price_end||0)
      @result['one_end'][date.year] = (@result['one_end'][date.year]||0) + (t.price_m2_end||0)
      @result['one_start'][date.year] = (@result['one_start'][date.year]||0) + (t.price_m2_start||0)
      @result['prices_percent'][date.year] = (@result['prices_percent'][date.year]||0) + (t.percent_decline||0)

    end



    @result['years']=years


    @result['qty'] = ObjectTender.get_qty_tenders_count
    @result['qty_sum'] = ObjectTender.get_qty_tenders_sum
    @result['qty_years'] = Array.new
    @result['qty_drilldowns'] = Hash.new
    ObjectTender.select('YEAR(DataFinish) as year').distinct.each do |y|
      @result['qty_years'].push y.year
      @result['qty_drilldowns'][y.year]=ObjectTender.get_qty_tenders_drilldown_by_year y.year

    end
    @tenders = Array.new

    ObjectTender.where('ObjectId IS NOT NULL').includes(:obj).includes(:organization).each do |t|
      tender = Hash.new
      tender['status']=t.status
      tender['id']=t.id
      tender['year_finish']=t.date_finish.year
      tender['month_finish']=t.date_finish.month
      tender['type']=t.type
      tender['percent']=t.percent_decline||0
      tender['price_m2_end']=t.price_m2_end||0
      tender['price_m2_start']=t.price_m2_start||0
      tender['price_end']=t.price_end||0
      tender['price_start']=t.price_begin||0
      tender['bid_all']=t.bid_all||0
      tender['bid_accept']=t.bid_accept||0
      tender['bid_reject']=(t.bid_all||0)-(t.bid_accept||0)
      tender['uk_only']=false
      tender['without_uk']=false
      tender['organization']= t.organization!=nil ? t.organization.name : '-'
      tender['date_finish'] = Date.parse(t.date_finish.to_s)
      tender['number'] = t.number


      if t.obj != nil
        tender['object_address']=t.obj.adress
        tender['object_power']=t.obj.power
        tender['appointment']=t.obj.appointment
        tender['series']=(t.obj.seria=='ИНД') ? t.obj.seria : 'Сер'
        @tenders.push tender
      end

    end

    @objectTenders = Array.new
    Obj.where(is_archive: 0).includes(:object_tenders).each do |obj|
      if obj.year_correct=="Нет в АИП"
        next;
      end
      object = Hash.new
      object['id']=obj.id
      object['year_enter']=obj.year_correct
      object['appointment']=obj.appointment
      object['power']=obj.power
      object['address']=obj.adress
      object['series']=(obj.seria=='ИНД') ? obj.seria : 'Сер'
      object['tenders']=Array.new
      tenders_sum = 0
      tenders = obj.tenders.where(status: 'проведен')
      if (tenders.count == 0)
        next;
      end

      tenders.each do |t|
        tender = Hash.new
        tender['sum']=t.price_end||0
        tender['type']=t.type
        tender['organization']=t.organization!=nil ? t.organization.name : '-'
        tender['date_finish']=Date.parse(t.date_finish.to_s)
        tender['bid_accept']=t.bid_accept||0
        tender['bid_all']=t.bid_all||0
        tender['price_start']=t.price_begin||0
        tender['price_end']=t.price_end||0
        tender['percent']=t.percent_decline||0
        tenders_sum += t.price_end||0
        object['tenders'].push tender
      end
      object['tenders_sum']=tenders_sum
      object['price_m2']=tenders_sum/(obj.power||1)

      @objectTenders.push(object);
    end

    res = ''
    res += 'tenders:'+ @tenders.to_json.html_safe
    res+= ',objects_tenders:'+@objectTenders.to_json.html_safe
    res += ',tenders_data:'+ @result.to_json.html_safe


    response=params['callback']+'({'
    response+= res
    response += '})'

    render :js => response
  end


end
