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

      objects.push(object)
    end
    @districts = Obj.getAllDistricts
    @years = Obj.getAllEnterYears
    @appointments = Obj.getAllAppointmentType

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
