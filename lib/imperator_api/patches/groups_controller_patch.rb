require_dependency 'groups_controller'

module ImperatorApi
  module Patches
    module GroupsControllerPatch
      extend ActiveSupport::Concern

      PARAMS_TO_FILTER = [:name]

      included do
        before_filter :filter_unallowed_params, only: :update,
                                                if: :base_controller?
      end

      private

      def base_controller?
        !is_a?(ImperatorApi::V1::GroupsController)
      end

      def filter_unallowed_params
        params[:group].delete_if do |key, _|
          PARAMS_TO_FILTER.include? key.to_sym
        end
      end
    end
  end
end
