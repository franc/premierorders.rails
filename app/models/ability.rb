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
    can [:read, :update], User, :id => user.id
 
    if user.role? :franchisee
      can [:create, :read, :update, :place_order], Job do |job|
        job.new_record? || job.is_manageable_by(user)  
      end
      can :destroy, Job do |job|
        job.is_manageable_by(user) && (job.status.nil? || job.status == 'Created')
      end
      can [:create, :read, :update, :destroy], [JobProperty, JobItem] do |x|
        x.new_record? || x.job.is_manageable_by(user)
      end
      can [:create, :read, :update, :destroy], JobItemProperty do |x|
        x.new_record? || x.job_item.job.is_manageable_by(user)
      end

      can :manage, AddressBook, :user_id => user.id
      can :manage, Address do |addr|
        addr.address_books.any?{|b| b.user_id == user.id}
      end
    end

    if user.role? :product_admin
      can :manage, [Item, ItemComponent, ItemProperty, Property, PropertyValue, Job, JobProperty, JobItem, JobItemProperty]
    end

    if user.role? :customer_service
      can :read, [Item, ItemComponent, ItemProperty, Property, PropertyValue, Franchisee, FranchiseeContact]
      can :manage, [Job, JobProperty, JobItem, JobItemProperty, User, Address]
    end

    if user.role? :accounting
      can :read, [Item, ItemComponent, ItemProperty, Property, PropertyValue, Job, JobProperty, JobItem, JobItemProperty]
      can :manage, [User, Franchisee, FranchiseeContact, Address]
    end

    if user.role? :admin
      can :manage, :all
    end
  end
end
