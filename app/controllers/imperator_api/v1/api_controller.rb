module ImperatorApi
  module V1
    class ApiController < ::ActionController::Base
      include Concerns::ErrorHandling

      def route_not_found
        render_api_not_found('route not found', :bad_request)
      end
    end
  end
end
