module ImperatorApi
  module V1
    class TimelogController < ::TimelogController

      accept_api_auth :create, :update, :destroy
      include Concerns::ErrorHandling
      include Concerns::AccessControl

      def create
        @project = Project.where(name: "Nieświadczenie usług").first!
        params[:time_entry][:issue_id] = '' 
        @time_entry ||= TimeEntry.new(:project => @project, :user => User.current, :spent_on => User.current.today)
        @time_entry.safe_attributes = params[:time_entry]
        if @time_entry.project && !User.current.allowed_to?(:log_time, @time_entry.project)
          @project = nil
          respond_to do |format|
            format.api { render json: {:message => :notice_not_authorized}, status: 403 }
          end
          return false
        end
        call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })
        if @time_entry.save
          respond_to do |format|
            format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
          end
        else
          respond_to do |format|
            format.api  { render_validation_errors(@time_entry) }
          end
        end
      end

      def update
        @time_entry.safe_attributes = params[:time_entry]

        call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

        if @time_entry.save
          respond_to do |format|
            format.api  { render_api_ok }
          end
        else
          respond_to do |format|
            format.api  { render_validation_errors(@time_entry) }
          end
        end
      end

      def bulk_update
        attributes = parse_params_for_bulk_time_entry_attributes(params)

        unsaved_time_entry_ids = []
        @time_entries.each do |time_entry|
          time_entry.reload
          time_entry.safe_attributes = attributes
          call_hook(:controller_time_entries_bulk_edit_before_save, { :params => params, :time_entry => time_entry })
          unless time_entry.save
            respond_to do |format|
              format.api { render json: {}, status: 422 }
            end
            unsaved_time_entry_ids << time_entry.id
            set_flash_from_bulk_time_entry_save(@time_entries, unsaved_time_entry_ids)
            return
          end
        end
        set_flash_from_bulk_time_entry_save(@time_entries, unsaved_time_entry_ids)
        respond_to do |format|
          format.api { render json: {}, status: 204 }
        end
      end

      def destroy
        destroyed = TimeEntry.transaction do
          @time_entries.each do |t|
            unless t.destroy && t.destroyed?
              raise ActiveRecord::Rollback
            end
          end
        end

        respond_to do |format|
          format.api  {
            if destroyed
              render_api_ok
            else
              render_validation_errors(@time_entries)
            end
          }
        end
      end

      private

      def find_time_entries
        @time_entries = TimeEntry.where(:id => params[:id] || params[:ids]).to_a
        raise ActiveRecord::RecordNotFound if @time_entries.empty?
        @projects = Project.where(name: "Nieświadczenie usług")
        @project = Project.where(name: "Nieświadczenie usług").first!
      end
    end
  end
end