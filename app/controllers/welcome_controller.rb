class WelcomeController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС"
  end

  def index



    @user = User.new(:email => 'ezhkov@kpugs.ru', :password => 'kpugsPassEzhkov', :password_confirmation => 'kpugsPassEzhkov')
    #@user.save!
    @user = User.new(:email => 'belyuchenko@kpugs.ru', :password => 'kpugsPassBAV', :password_confirmation => 'kpugsPassBAV')
    #@user.save!

  end
end
