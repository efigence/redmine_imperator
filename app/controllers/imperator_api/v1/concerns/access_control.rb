module ImperatorApi
  module V1
    module Concerns
      module AccessControl
        extend ActiveSupport::Concern
        extend ImperatorApi::V1::Concerns::ErrorHandling

        included do
          def render_api_im_a_teapot
            render_imperator_api_error(message: "I\'m a teapot", status: 418)
          end
        end
      end
    end
  end
end
