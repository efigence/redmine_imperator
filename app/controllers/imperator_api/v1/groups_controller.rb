module ImperatorApi
  module V1
    class GroupsController < ::GroupsController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
