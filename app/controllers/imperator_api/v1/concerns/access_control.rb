module ImperatorApi
  module V1
    module Concerns
      module AccessControl
        extend ActiveSupport::Concern
        extend ImperatorApi::V1::Concerns::ErrorHandling

        included do
          prepend_before_filter :authenticate_with_imperator_api_key!

          def render_api_im_a_teapot
            render_imperator_api_error(message: "I\'m a teapot", status: 418)
          end
        end

        private

        def debug_auth_headers
          http_envs = {}.tap do |envs|
            request.headers.each do |key, value|
              envs[key] = value if key.downcase.starts_with?('http')
            end
          end

          puts "Received #{request.method.inspect} to #{request.url.inspect} from #{request.remote_ip.inspect}. Processing with HTTP_ headers #{http_envs.inspect} and params #{params.inspect}"
        end

        def debug_response
          puts "Responding with #{response.status.inspect} => #{response.body.inspect}"
        end

        def authenticate_with_imperator_api_key!
          if ImperatorApi::Key.new.matches?(request.headers['X-Imperator-API-Key'].to_s)
            logger.debug 'Authenticated with X-Imperator-API-Key'
          else
            return render json: { errors: 'Invalid X-Imperator-API-Key' },
                          status: :unauthorized
          end
        end
      end
    end
  end
end
