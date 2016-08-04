module ImperatorApi
  module V1
    class ProjectsController < ::ProjectsController
      after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
        if controller.request.post?
          controller.send :expire_action, :controller => '/welcome', :action => 'robots'
        end
      end
      accept_api_auth :index, :show, :create, :update, :destroy, :copy_source,
                      :copy, :archive, :unarchive, :close, :reopen
      include Concerns::ErrorHandling
      include Concerns::AccessControl

      def copy_source
        @issue_custom_fields = IssueCustomField.sorted.to_a
        @trackers = Tracker.sorted.to_a
        @source_project = Project.find(params[:id])
        @project = Project.copy_from(@source_project)
        @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
        @source_for_copy = @project.attributes
        @source_for_copy['enabled_modules'] = @project.enabled_modules
        @source_for_copy['trackers'] = @project.trackers
        @source_for_copy['custom_values'] = @project.custom_values
        @source_for_copy['issue_custom_fields'] = @project.issue_custom_fields
        @source_for_copy['all_available_issue_custom_fields'] = @issue_custom_fields
        @source_for_copy['all_available_trackers'] = @trackers
        respond_to do |format|
          format.api { render json: @source_for_copy, status: 200 }
        end
      end

      def copy
        @source_project = Project.find(params[:id])
        Mailer.with_deliveries(params[:notifications] == '1') do
          @project = Project.new
          @project.safe_attributes = params[:project]
          if @project.copy(@source_project, :only => params[:only])
            @project.enabled_modules = EnabledModule.where(project_id: @project.id).select { |x| params[:enabled_modules].include?(x.name) } unless params[:enabled_modules].blank?
            @project.trackers = Tracker.all.select { |x| params[:trackers].include?(x.name) } unless params[:trackers].blank?
            @project.issue_custom_fields = IssueCustomField.all.select { |x| params[:issue_custom_fields].include?(x.name) } unless params[:issue_custom_fields].blank?
            @project.custom_values = CustomValue.where(customized_type: 'Project').select { |x| params[:custom_values].include?(x.value) if x.value != '' } unless params[:custom_values].blank?
            respond_to do |format|
              format.api { render json: @project, status: 201 }
            end
          else
            respond_to do |format|
              format.api { render json: @project.errors, status: 422 }
            end
          end
        end
      end
    end
  end
end
