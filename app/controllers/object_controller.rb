class ObjectController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Объекты"
  end

  def index

    #puts Obj.get_years_enters_plan
    #puts Obj.get_years_enters_fact
  end


end
