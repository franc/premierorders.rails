class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    user ||= User.new # guest user
 
    if user.role? :franchisee
      can :manage, User, :id => user.id
      can :manage, Job, :customer_id => user.id
      can :manage, [JobProperty, JobItem] do |x|
        x.job.customer_id == user.id
      end
      can :manage, JobItemProperty do |ip|
        ip.job_item.job.customer_id == user.id
      end
      can :manage, AddressBook, :user_id => user.id
      can :manage, Address do |addr|
        addr.address_books.any?{|b| b.user_id == user.id}
      end
    end

    if user.role? :product_admin
      can :manage, [Item, ItemComponent, Property, PropertyValue]
      can :admin_job, Job
    end

    if user.role? :admin
      can :manage, :all
      can :assign_roles, User
      can :admin_job, Job
    end
  end
end