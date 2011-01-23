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
> sudo gem install rails

Next, you will need to clone the repository from github. The best way to do this is to fork the skooter/premierorders.rails repository on github, then clone your
repository to get a copy on your local machine

> git clone git@github.com:my_github_username/premierorders.rails.git

This will create a working directory called premierorders.rails. Go into that directory, and run 'bundle install' to get the necessary dependencies.

> cd premierorders.rails
> bundle install

Now, you will need to create a new postgres database.

> sudo -u postgres psql
> psql> create user pg_orders password 'pg_orders';
> psql> create database pg_dev owner pg_orders;
> psql> \q

Now, log in as the pg_orders user so that ownership of tables will be correct when you restore the current database backup.

> psql -U pg_orders pg_dev
> psql> \i db/history/pg_dev.dump
> psql> \q

At this point, you should be able to start the server

> rails server

Point your browser to http://localhost:3000 and away you go!

If you need to create a user for yourself to be able to log in, the easiest way to do that is to use the rails console:

> rails c
> irb(main):001:0> User.create(:email => 'me@myself.com', :password => 'myfancypass')
> irb(main):001:0> quit

