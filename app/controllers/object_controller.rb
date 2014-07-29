class ObjectController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Объекты"
  end

  def index
    authorize! :index, self
    #puts Obj.get_years_enters_plan
    #puts Obj.get_years_enters_fact
    @objects = Obj.all
    render "index2"
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

end
