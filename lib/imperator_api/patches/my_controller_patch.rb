require_dependency 'my_controller'

module ImperatorApi
  module Patches
    module MyControllerPatch
      extend ActiveSupport::Concern

      PARAMS_TO_FILTER = [:login, :firstname, :lastname, :email, :group_ids, :status]

      included do
        before_filter :filter_unallowed_params, only: :account
      end

      private

      def filter_unallowed_params
        return if request.get? || params[:user].blank?
        params[:user].delete_if do |key, _|
          PARAMS_TO_FILTER.include? key.to_sym
        end
      end
    end
  end
end
