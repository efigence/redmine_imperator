module ImperatorApi
  module V1
    class ProjectsController < ::ProjectsController
      after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
        if controller.request.post?
          controller.send :expire_action, :controller => '/welcome', :action => 'robots'
        end
      end
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
