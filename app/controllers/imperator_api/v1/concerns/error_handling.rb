module ImperatorApi
  module V1
    module Concerns
      module ErrorHandling
        extend ActiveSupport::Concern

        included do
          rescue_from ActiveRecord::RecordNotFound, with: :render_api_not_found
          rescue_from(ActionController::RoutingError) do
            return render json: {
              error: 'The resource you were looking for does not exist'
            }
          end
          rescue_from(StandardError, RuntimeError, Exception) do |exception|
            if Rails.env.production?
              message = "We're sorry, but something went wrong. " \
"We've been notified about this issue and we'll take a look at it shortly."
              render_imperator_api_error(message: message, status: :internal_server_error)
            else
              render_imperator_api_error(message: exception.message + exception.backtrace.to_a.slice(0, 4).join(', '),
                           status: :internal_server_error)
            end
          end

          protected

          # redmie override!
          # def render_403(options = {})
          #   @project = nil
          #   render_imperator_api_error({ message: :notice_not_authorized, status: 403 }.merge(options))
          #   false
          # end

          # redmie override!
          # def render_404(options = {})
          #   render_imperator_api_error({ message: :notice_file_not_found, status: 404 }.merge(options))
          #   false
          # end

          # redmie override!
          # def render_error(arg)
          #   arg = { message: arg } unless arg.is_a?(Hash)
          #
          #   @message = arg[:message]
          #   @message = l(@message) if @message.is_a?(Symbol)
          #   @status = arg[:status] || 500
          #
          #   respond_to do |format|
          #     format.json { render json: { error: { message: @message } }, status: @status }
          #     format.any { head @status }
          #   end
          # end

          def render_imperator_api_error(arg)
            render_error(arg)
          end

          # redmie override!
          # def render_api_head(status)
          #   # #head would return a response body with one space
          #   return render text: '', status: status, layout: nil
          # end

          # redmie override!
          # def render_api_errors(*messages)
          #   @error_messages = messages.flatten
          #   return render template: 'common/error_messages.api', status: :unprocessable_entity, layout: nil
          # end

          def render_api_not_found
            render_imperator_api_error(message: I18n.t('errors.messages.not_found').to_s, status: :not_found)
          end

          # redmie override!
          def authorize(ctrl = params[:controller], action = params[:action], global = false)
            # hack
            ctrl = ctrl.to_s.gsub(/imperator_api\/v1\//, '')

            allowed = User.current.allowed_to?({ controller: ctrl, action: action },
                                               @project || @projects,
                                               global: global)
            if allowed
              true
            else
              if @project && @project.archived?
                render_403 message: :notice_not_authorized_archived_project
              else
                deny_access
              end
            end
          end
        end
      end
    end
  end
end
