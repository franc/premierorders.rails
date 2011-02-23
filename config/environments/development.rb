PgRails::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.active_record.logger = Logger.new('log/activerecord.log')
  config.active_record.logger.level = Logger::INFO

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "mail.premierorders.net",
    :port                 => 587,
    :domain               => 'premierorders.net',
    :user_name            => 'mailer@premierorders.net',
    :password             => 'Skooter123',
    :authentication       => 'plain',
    :enable_starttls_auto => false  
  }

  config.action_mailer.default_url_options = { :protocol => 'https', :host => "tldev.premierorders.net" }
end

