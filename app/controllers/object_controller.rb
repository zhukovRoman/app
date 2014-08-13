class ObjectController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Объекты"
  end

  def index
    authorize! :index, self
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
      object['appointment']=o.appointment
      object['payed']=o.object_finance.pay_current_year||0
      object['limit']=o.object_finance.year_limit||0
      object['complete']=o.object_finance.complete_work||0
      object['incomplete']=o.object_finance.incomplete_work||0
      object['lat']=o.lat
      object['lng']=o.lng
      object['id']=o.id
      object['adress']=o.adress
      object['power']=o.power
      object['power_measure']=o.power_measure
      object['year_plan']=object['year']
      object['AIP']=o.object_finance.sumAIP
      objects.push(object)
    end
    @districts = Obj.getAllDistricts
    @years = Obj.getAllEnterYears
    @appointments = Obj.getAllAppointmentType
    puts Obj.where(general_builder: '315 УНР').take.organization.inspect
    render "index3"
  end

  def finance
    authorize! :index, self
  end

  def organizations
    authorize! :index, self
    require 'json'

    @organizations = Array.new
    #temp = Organization.includes(:objs)
    Organization.includes(:objs, objs: :object_finance).where(vw_ObjectForMobileInfo_NEW: {ObjectArchve: 0}).each do |org|
      if (org.objs.count==0)
        next
      end
      temporary_obj = Hash.new
      temporary_obj['name']=org.name
      temporary_obj['id']=org.id
      temporary_obj['payed_left']=(org.residue_summ_for_all_objects/1000000).round
      temporary_obj['work_complete']=(org.work_complete_summ_for_all_objects/1000000).round
      temporary_obj['work_incomplete']=(org.work_left_summ_for_all_objects/1000000).round
      org_objects = Array.new
      org.objs.each do |o|
        obj = Hash.new
        obj['id']=o.id
        obj['name']=(o.name||'')[0,200]
        obj['address']=(o.adress||'')[0,200]
        obj['region']=o.region
        obj['year']=o.getYearCorrect
        obj['network']=o.SMR_external_network||'-'
        obj['network_delay']=o.SMR_external_network_delay||0
        obj['constructive']=o.SMR_constructive||'-'
        obj['constructive_delay']=o.SMR_constructive_delay||0
        obj['internal']=o.SMR_internal||'-'
        obj['internal_delay']=o.SMR_internal_delay||0
        org_objects.push(obj)
      end
      temporary_obj['objects']=org_objects
      temporary_obj['tenders']=org.get_tenders
      @organizations.push(temporary_obj)
    end

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

  def overdue
    @objects = Obj.overdueObjects
  end

end
