require File.expand_path(File.dirname(__FILE__) + '/../../test/test_helper')

class ApiTest < Redmine::ApiTest::Base
  fixtures :users, :email_addresses, :members, :member_roles, :roles, :projects

  test 'GET /api.json should return users' do
    get '/api.json', {}, credentials('admin')

    assert_response :success
    assert_equal 'application/json', response.content_type
    assert_select 'users', assigns(:users).size
  end

  def test_create
    assert_difference('User.count') do
      post '/api.json', {
        user: {
          login: 'foo', firstname: 'Firstname', lastname: 'Lastname',
          mail: 'foo@example.net', password: 'secret123'
        }
      }, {}
      assert_response 201
    end
  end
end
