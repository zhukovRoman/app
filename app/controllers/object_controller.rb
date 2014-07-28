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
  end

  def finance
    authorize! :index, self
  end


end
