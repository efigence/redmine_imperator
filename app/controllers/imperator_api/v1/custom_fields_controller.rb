module ImperatorApi
  module V1
    class CustomFieldsController < ::CustomFieldsController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
    end
  end
end
