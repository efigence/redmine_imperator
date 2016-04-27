require File.expand_path(File.dirname(__FILE__) + '/../../test/test_helper')

class ApiTest < ActionController::TestCase
  def setup
    @controller  = ApiController.new
    @request     = ActionController::TestRequest.new
    @response    = ActionController::TestResponse.new
  end

  def test_api_should_work
    assert_difference('User.count') do
      post :create, {
        :user => {
          :login => 'foo', :firstname => 'Firstname', :lastname => 'Lastname',
          :mail => 'foo@example.net', :password => 'secret123'}
        },
        {}
      assert_response 302
    end
  end
end
