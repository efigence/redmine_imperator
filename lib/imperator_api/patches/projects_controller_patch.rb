require_dependency 'projects_controller'

module ImperatorApi
  module Patches
    module ProjectsControllerPatch
      extend ActiveSupport::Concern

      PARAMS_TO_FILTER = [:name, :description, :identifier, :homepage,
                          :is_public, :parent_id, :inherit_members].freeze

      included do
        before_filter :filter_unallowed_params, only: :update,
                                                if: :base_controller?
      end

      private

      def base_controller?
        !is_a?(ImperatorApi::V1::ProjectsController)
      end

      def filter_unallowed_params
        params[:project].delete_if do |key, _|
          PARAMS_TO_FILTER.include? key.to_i
        end
      end
    end
  end
end
