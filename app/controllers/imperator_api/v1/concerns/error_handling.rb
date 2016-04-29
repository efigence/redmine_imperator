module ImperatorApi
  module V1
    module Concerns
      module ErrorHandling
        extend ActiveSupport::Concern

        included do
          rescue_from ActiveRecord::RecordNotFound, with: :not_found
          rescue_from(ActionController::RoutingError) do
            render json: {
              error: 'The resource you were looking for does not exist'
            }
          end
          rescue_from(StandardError, Exception) do |exception|
            if Rails.env.production?
              messsage = "We're sorry, but something went wrong. " \
"We've been notified about this issue and we'll take a look at it shortly."
              render_error(message, :internal_server_error)
            else
              render_error(exception.message, :internal_server_error)
            end
          end

          def not_found
            render_error(I18n.t('errors.messages.not_found').to_s, :not_found)
          end

          def render_error(message, status)
            render json: { error: { message: message } },
                   status: status
          end
        end
      end
    end
  end
end
