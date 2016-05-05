module ImperatorApi
  module V1
    class ProjectsController < ::ProjectsController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
