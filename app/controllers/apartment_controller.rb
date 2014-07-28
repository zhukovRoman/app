class ApartmentController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Продажи"
  end

  def index

  end

  def index2
    #puts current_user.inspect()
    authorize! :index, self
  end
end
