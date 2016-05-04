module ImperatorApi
  module V1
    class ProjectsController < ::ProjectsController
      include Concerns::ErrorHandling
    end
  end
end
