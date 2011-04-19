class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "#{exception.message} (#{exception.action} #{exception.subject})"
    redirect_to :jobs
  end

  def ping
    render :json => {:ok => true}
  end

  def offline
    render :layout => false
  end

  def manifest
    text = <<-MANIFEST
      CACHE MANIFEST
      # version 1.0.45
      /offline.html
      /catalog_orders

      /images/Premier-Logo.jpg
      /stylesheets/scaffold.css
      /stylesheets/ui-lightness/jquery-ui-1.8.6.custom.css

      /javascripts/jquery.js
      /javascripts/rails.js
      /javascripts/jquery-ui-1.8.7.custom.min.js
      /javascripts/jquery.validate.min.js
      /javascripts/jquery.loading.1.6.4.min.js
      /javascripts/json2.js

      /javascripts/application.js
      /javascripts/path.min.js
      /javascripts/catalog_orders.js

      FALLBACK:
      # The following fallback patterns exist so that the timestamped urls that will exist in the page rendered by rails
      # will fall back correctly to their non-timestamped counterparts

      /stylesheets/scaffold.css                            /stylesheets/scaffold.css
      /stylesheets/ui-lightness/jquery-ui-1.8.6.custom.css /stylesheets/ui-lightness/jquery-ui-1.8.6.custom.css

      /javascripts/jquery.js                               /javascripts/jquery.js
      /javascripts/rails.js                                /javascripts/rails.js
      /javascripts/jquery-ui-1.8.7.custom.min.js           /javascripts/jquery-ui-1.8.7.custom.min.js
      /javascripts/jquery.validate.min.js                  /javascripts/jquery.validate.min.js
      /javascripts/jquery.loading.1.6.4.min.js             /javascripts/jquery.loading.1.6.4.min.js
      /javascripts/json2.js                                /javascripts/json2.js

      /javascripts/application.js                          /javascripts/application.js
      /javascripts/path.min.js                             /javascripts/path.min.js
      /javascripts/catalog_orders.js                       /javascripts/catalog_orders.js

      # default fallback route
      /                                                    /offline.html

      NETWORK:
      /catalog_orders/catalog_json
    MANIFEST

    send_data text.gsub(/^\s*/,''), :type => 'text/cache-manifest; charset=iso-8859-1; header=present'
  end
end
