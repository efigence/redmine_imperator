module ImperatorApi
  module V1
    class ApiController < ::ActionController::Base
      include Concerns::ErrorHandling
      include Concerns::AccessControl

      def route_not_found
        render json: { error: { message: 'route not found' } }, status: :bad_request
      end
    end
  end
end
