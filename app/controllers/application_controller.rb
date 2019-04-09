class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  force_ssl if Rails.env.production?

  rescue_from NotFoundException, ActionView::MissingTemplate do |ex|
    raise ActionController::RoutingError.new("Not Found")
  end

  before_action :set_tenant

  private

  def set_tenant
    Tenant.set_for_host(request.host)
  end
end
