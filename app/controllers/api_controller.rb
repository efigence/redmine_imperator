class ApiController < UsersController # < ActionController::Base
  unloadable
  #before_filter :set_current_user

  # appliction_controller
  skip_before_filter :verify_authenticity_token
  skip_before_filter :session_expiration, :user_setup, :check_if_login_required,
                     :check_password_change, :set_localization

  # users_controller
  skip_before_filter :require_admin
  accept_api_auth :index, :show, :create, :update, :destroy
  before_filter :find_user, :only => [:show, :edit, :update, :destroy]
  accept_api_auth :index, :show, :create, :update, :destroy

  # custom
  before_filter :disable_sudo_mode

  def index
    super
  end

  def create
    super
  end

  def disable_sudo_mode
    SudoMode.disable!
  end
end
