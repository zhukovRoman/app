class ObjectController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Объекты"
  end

  def index
    authorize! :index, self
    require 'json'
    @data = Hash.new
    @data['objects']=Array.new
    objects = @data['objects']
    Obj.notArchive.each do |o|
      object = Hash.new
      object['okrug']=o.region_name
      object['GPZU'] = o.getGPZUStatus
      object['year'] = o.getYearCorrect.to_s
      object['MGE']=o.getMGEStatus.to_s
      object['razresh']=o.getRazreshStatus.to_s
      object['appointment']=o.object_finance.appointment_type
      object['payed']=o.object_finance.current_year_payd||0
      object['limit']=o.object_finance.year_limit||0
      object['complete']=o.object_finance.complete_work||0
      object['incomplete']=o.object_finance.incomplete_work||0
      objects.push(object)
    end
    @districts = Obj.getAllDistricts
    @years = Obj.getAllEnterYears
    @appointments = ObjectFinance.getAllAppointmentType
    render "index3"
  end

  def finance
    authorize! :index, self
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
