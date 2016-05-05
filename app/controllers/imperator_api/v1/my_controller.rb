module ImperatorApi
  module V1
    class MyController < ::MyController
      include Concerns::ErrorHandling
      include Concerns::AccessControl
      prepend_before_filter :render_api_im_a_teapot
    end
  end
end
