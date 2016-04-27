class ApiController < UsersController # < ActionController::Base
  unloadable
  accept_api_auth :index, :create
  before_filter :set_current_user
  skip_before_filter :check_if_login_required
  skip_before_filter :verify_authenticity_token

  def index
    super
  end

  def create
    super
  end
end
