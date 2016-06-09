module ImperatorApi
  module V1
    class ProjectsController < ::ProjectsController
      after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
        if controller.request.post?
          controller.send :expire_action, :controller => '/welcome', :action => 'robots'
        end
      end
      accept_api_auth :index, :show, :create, :update, :destroy, :copy
      include Concerns::ErrorHandling
      include Concerns::AccessControl

      def copy
        @issue_custom_fields = IssueCustomField.sorted.to_a
        @trackers = Tracker.sorted.to_a
        @source_project = Project.find(params[:id])
        Mailer.with_deliveries(params[:notifications] == '1') do
          @project = Project.new
          @project.safe_attributes = params[:project]
          if @project.copy(@source_project, :only => params[:only])
            respond_to do |format|
              format.api { render json: @project, status: :created }
            end
          else
            respond_to do |format|
              format.api { render json: {}, status: :conflict }
            end
          end
        end
      end
    end
  end
end
