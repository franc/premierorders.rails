PremierGarage.com Order Bridge Setup
====================================

Required software
-----------------

Rails 3.0.1 or later
Postgres 8.4 or later

Setup
-----

Depending upon your system, you may need to install Ruby from source in order to get Rails 3 to work. Follow the directions in the INSTALL file to do so if necessary.

To obtain Rails run:

    sudo gem install rails

Next, you will need to clone the repository from github. The best way to do this is to fork the skooter/premierorders.rails repository on github, then clone your
repository to get a copy on your local machine

    git clone git@github.com:my_github_username/premierorders.rails.git

This will create a working directory called premierorders.rails. Go into that directory, and run 'bundle install' to get the necessary dependencies.

    cd premierorders.rails
    bundle install

Now, you will need to create a new postgres database.

    sudo -u postgres psql
    psql> create user pg_orders password 'pg_orders';
    psql> create database pg_dev owner pg_orders;
    psql> \q

Now, log in as the pg_orders user so that ownership of tables will be correct when you restore the current database backup.

    psql -U pg_orders pg_dev
    psql> \i db/history/pg_dev.dump
    psql> \q

At this point, you should be able to start the server

    rails server

Point your browser to http://localhost:3000 and away you go!

If you need to create a user for yourself to be able to log in, the easiest way to do that is to use the rails console:

    rails c
    irb(main):001:0> User.create(:email => 'me@myself.com', :password => 'myfancypass')
    irb(main):001:0> quit


Architecture
============

Overall, this is a very standard Rails 3 application, with just a few pieces that deviate from the standard Rails application architecture.
The primary architectural decisions of interest are related to the representations of items and assemblies of items.

Items & Assemblies
------------------

The base class Item is the foundation for both primitive (or atomic) items, and for compound assemblies. Any item may have component parts.
Each item is related to its parts, if it has any, by an ItemComponent record. Both Item and ItemComponent are polymorphic; that is, they
take advantage of Rails' single-table inheritance feature to allow overriding of functionality. ItemComponent subclasses define the types
of relationships that may exist between items and their subcomponents. Many such association classes are specific to a certain item subtype. 
To facilitate automatic UI generation, each Item subclass must define lists of required an optional component association types that
are applicable to that class. A simple example will illustrate:

The 'Cabinet' item type, defined in app/models/items/cabinet.rb defines a class method, component_association_types which overrides the same-named
method in the Item base class. It defines one required association, of type Items::CabinetShell, and two optional associations, Items::CabinetDrawer
and Items::CabinetShelf. The Cabinet class, however, does not override any instance methods of the Item class, meaning that its semantics for
price calculation and so forth are all simply derived directly from Item's. So, the principle utility of this class is actually to define association
(and property, which we'll get to later) types appropriate to cabinets.

The association classes define the type of component that must be the target of the association by overriding the component_type class method; for 
example, CabinetShell specifies that the target of the cabinet-shell association must be an instance of type Items::Shell. It does not define 
any overrides of the basic ItemComponent methods, so this is a simple example. For a more interesting example, we may look to Items::CabinetShelf.

Items::CabinetShelf does not merely override the component_types class method, but also the qty_expr and cost_expr instance methods. These
methods are the workhorses of the assembly model: they are used to compose the pricing expressions used to determine what items should cost
based upon the prices of their components. Each subclass of ItemComponent may override these methods as appropriate.

Both Item and ItemComponent define (and thus provide an opportunity to override) the cost_expr method. This method takes as its argument an
instance of type ItemQueries::QueryContext, and returns an Option[Expr]. Option and other functional-programming staple classes can be found 
in lib/fp; item query utilities and classes are found in lib/item_queries. Computation of cost expressions involves a recursive-descent, depth-
first traversal of a component hierarchy. 

Expressions
-----------

Expressions are composed through use of a number of combinators defined in the file lib/expressions.rb. The general model is simple: an expression
representing the price (or weight, or other calculable value) is composed as an object graph using these combinators, and the expression may then
be either compiled to a string (for export to D'Vinci) or evaluated directly for a set of input variables. 

Properties
----------

Each Item and ItemComponent instance may be configured with one or more property values. The types of properties that a given class may
be configured with are specified by the optional_properties and required_properties class methods, each of which may return an array
of PropertyDescriptor objects.

A Property instance forms a collection of PropertyValue instances. Both Property instances (i.e. collections of values that the property can
take on) and PropertyValue instances may be shared across items and item components. This well-normalized model allows for changes to property
values to be made in a single place, and shared wherever necessary.

PropertyValue instances do not utilize the standard Rails single-table inheritance model; instead, they implement a more flexible model. The value
of any given property may have arbitrary structure, and values are encoded as JSON objects stored in the database. Each PropertyValue instance
may specify a number of Ruby modules that implement logic for accessing the values in these JSON objects; since JSON objects and Ruby modules may
both be composed, it is then possible to "mix together" multiple property traits to obtain a property type that is most appropriate to a given domain.
The essence of this design is that composable JSON documents are used for data storage, and composable Ruby modules provide logic for accessing this
data. When a PropertyValue instance is retrieved from the database, the modules that apply to that value are selected and mixed in to the returned value.
Each Property submodule defines its value structure as a class method, in much the same manner as component association types, component types, and property
descriptors. Please see app/models/Property.rb for examples.

The descriptor/module structure of Properties and the reliance on JSON for the storage format also allows for automatic generation of UI components for
property editing. See app/views/items/_add_property.html.erb for the implementation of this UI generation. As a hint for understanding this code, it is written
entirely in continuation-passing style such and the form is rebuilt according to AJAX calls to the server that return property descriptor information.

Important System Information
============================

Both development and production servers are hosted on the tl.premierorders.net server, which is a virtual server hosted by RackSpace. 
Source code is stored in a GitHub git repository, and deployment is performed using the following manual process:

    ssh tl.premierorders.net
    > cd /var/www/premierorders.rails
    > git pull
    > touch tmp/restart.txt

Database backups are performed on an hourly basis by a cron job run from the root account. This job simply dumps the Postgres database
as text (the database is almost trivially small) and commits any changes to git. While this is a somewhat unconventional backup strategy,
it has the distinct advantage that it makes it possible to restore the exact database and corresponding source code state to any point
in history. While this approach cannot be assumed to be indefinitely scalable, the small size of the database makes it highly suitable
for the near term.

The Rails application is hosted on nginx (installed in /opt/nginx) and makes use of the Passenger gem.

The database is a simple PostgreSQL instance; connection information is available in the Rails environment files.
