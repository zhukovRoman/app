class ObjectsController < ApplicationController
  before_filter :authenticate_user!
  @@partName = "ГП УГС - Объекты"
  def index

  end
end
