module ImperatorApi
  module V1
    class UsersController < ::UsersController
      include Concerns::ErrorHandling
    end
  end
end
