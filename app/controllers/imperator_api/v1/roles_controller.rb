module ImperatorApi
  module V1
    class RolesController < ::RolesController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
