class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    puts user
    #can :index, ApartmentController if [1,2,3,4,5,6,7,10,11].include? user.id
    can :index, ApartmentController if true
    #can :index, TendersController if [1,2,4,5,6,7,10,11].include? user.id
    can :index, TendersController if true
    #can :index, EmployeeController if [1,2,4,5,6,7,8,9,10,11,12,13].include? user.id
    can :index, EmployeeController if true
    #can :index, ObjectController if [1,2,4,5,6,7,10,11,12,13].include? user.id
    can :index, ObjectController if true
    #can :organizations, ObjectController if [1,2,4,5,6,7,10,11,12,13].include? user.id
    can :organizations, ObjectController if true

    can :vacancies, EmployeeController if [1,2,4,8,9,10,11].include? user.id
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
