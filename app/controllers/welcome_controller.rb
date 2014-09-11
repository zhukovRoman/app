class WelcomeController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС"
  end

  def index
    @user = User.new(:email => 'oleneva@kpugs.ru', :password => '7fdur4hjf', :password_confirmation => '7fdur4hjf')
    #@user.save!
    #@user = User.new(:email => 'bakieva@kpugs.ru,', :password => 'k5dshfjk3', :password_confirmation => 'k5dshfjk3')
    #@user.save!

  end
end
