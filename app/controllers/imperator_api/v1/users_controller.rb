module ImperatorApi
  module V1
    class UsersController < ::UsersController
      include Concerns::ErrorHandling

      unloadable
      # before_filter :set_current_user

      # appliction_controller
      skip_before_filter :verify_authenticity_token
      skip_before_filter :session_expiration, :user_setup, :check_if_login_required,
                         :check_password_change, :set_localization

      # users_controller
      skip_before_filter :require_admin
      accept_api_auth :index, :show, :create, :update, :destroy
      before_filter :find_user, only: [:show, :edit, :update, :destroy]
      accept_api_auth :index, :show, :create, :update, :destroy

      # patch methods here like this
      def index
        super
      end
    end
  end
end
