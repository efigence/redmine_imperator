module ImperatorApi
  module V1
    class MembersController < ::MembersController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
