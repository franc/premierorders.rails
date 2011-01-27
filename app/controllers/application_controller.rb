class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "#{exception.message} (#{exception.action} #{exception.subject})"
    redirect_to :jobs
  end
end
