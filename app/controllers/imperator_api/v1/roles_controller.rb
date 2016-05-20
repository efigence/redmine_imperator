module ImperatorApi
  module V1
    class RolesController < ::RolesController
      accept_api_auth :index, :show, :create, :update, :destroy
      include Concerns::ErrorHandling
      include Concerns::AccessControl

      def create
        @role = Role.new(role_params)
        respond_to do |format|
          if @role.save
            format.api do
              render action: 'show', status: :created, location: role_url(@role)
            end
          else
            format.api { render_validation_errors(@role) }
          end
        end
      end

      def update
        respond_to do |format|
          if @role.update(role_params)
            format.api { render_api_ok }
          else
            format.api { render_validation_errors(@role) }
          end
        end
      end

      def destroy
        @role.destroy
        respond_to do |format|
          format.api { render_api_ok }
        end
      end

      private

      def role_params
        params.require(:role).permit(:name)
      end
    end
  end
end
