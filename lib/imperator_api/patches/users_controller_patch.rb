require_dependency 'users_controller'

module ImperatorApi
  module Patches
    module UsersControllerPatch
      extend ActiveSupport::Concern

      PARAMS_TO_FILTER = [:login, :firstname, :lastname, :email, :group_ids, :status]

      included do
        before_filter :filter_unallowed_params, only: :update,
                                                if: :base_controller?
      end

      private

      def base_controller?
        !is_a?(ImperatorApi::V1::UsersController)
      end

      def filter_unallowed_params
        params[:user].delete_if do |key, _|
          PARAMS_TO_FILTER.include? key.to_sym
        end
      end
    end
  end
end
