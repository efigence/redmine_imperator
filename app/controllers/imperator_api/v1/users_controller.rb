module ImperatorApi
  module V1
    class UsersController < ::UsersController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
