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
      can [:create, :read, :place_order], Job do |job|
        job.new_record? || job.is_manageable_by(user)  
      end
      can [:update, :destroy], Job do |job|
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

    if user.role? :franchise_support
      can [:read], [Job, JobProperty, JobItem, JobItemProperty, Franchisee, Address]
      can [:create, :update, :destroy], Job do |job|
        (job.status.nil? || job.status == 'Created')
      end
    end

    if user.role? :product_admin
      can :manage, [Item, ItemComponent, ItemProperty, Property, PropertyValue]
      can [:create, :read, :update, :cutrite, :download], [Job, JobProperty, JobItem, JobItemProperty]
      can :pg_internal_cap, :all
    end

    if user.role? :customer_service
      can :read, [Item, ItemComponent, ItemProperty, Property, PropertyValue, Franchisee, FranchiseeContact]
      can :manage, [ProductionBatch, User, Address]
      can [:create, :read, :update, :cutrite, :download], [Job, JobProperty, JobItem, JobItemProperty]
      can :pg_internal_cap, :all
    end

    if user.role? :accounting
      can :view_reports, :all
      can :read, [Item, ItemComponent, ItemProperty, Property, PropertyValue]
      can [:create, :read, :update, :cutrite, :download], [Job, JobProperty, JobItem, JobItemProperty]
      can :manage, [User, Franchisee, FranchiseeContact, Address]
      can :pg_internal_cap, :all
    end

    if user.role? :admin
      can :view_reports, :all
      can :pg_internal_cap, :all
      can :manage, :all
    end
  end
end
