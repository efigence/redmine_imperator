module ImperatorApi
  module V1
    class RolesController < ::RolesController
      accept_api_auth :index, :show, :create, :update, :destroy
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
