require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  module V1
    class TimelogTest < Redmine::ApiTest::Base

      setup do 
        Project.create(name: 'Nieświadczenie usług', identifier: 'nieswiadczenie')
      end

      def test_post_create
        skip if ENV['TRAVIS_TEST']
        assert_difference 'TimeEntry.count' do
          post '/imperator_api/v1/time_entries.json', {
            :project_id => 2,
            :time_entry => {:comments => 'Some work on TimelogControllerTest',
                            # Not the default activity
                            :activity_id => '11',
                            :issue_id => '1',
                            :spent_on => '2008-03-14',
                            :hours => '7.3'}}, credentials('admin')
          assert_response 201
        end
        t = TimeEntry.order('id DESC').first
        assert_not_nil t
        assert_equal 'Some work on TimelogControllerTest', t.comments
        assert_equal 'Nieświadczenie usług', t.project.name
        assert_equal nil, t.issue_id
        assert_equal 11, t.activity_id
        assert_equal 7.3, t.hours
      end

      def test_post_create_with_blank_issue
        skip if ENV['TRAVIS_TEST']
        assert_difference 'TimeEntry.count' do
          post '/imperator_api/v1/time_entries.json', {
            :project_id => 2,
            :time_entry => {:comments => 'Some work on TimelogControllerTest',
                            # Not the default activity
                            :activity_id => '11',
                            :issue_id => '',
                            :spent_on => '2008-03-14',
                            :hours => '7.3'}}, credentials('admin')
          assert_response 201
        end
        t = TimeEntry.order('id DESC').first
        assert_not_nil t
        assert_equal 'Some work on TimelogControllerTest', t.comments
        assert_equal 'Nieświadczenie usług', t.project.name
        assert_nil t.issue_id
        assert_equal 11, t.activity_id
        assert_equal 7.3, t.hours
      end

      def test_update
        entry = TimeEntry.find(1)
        assert_equal 1, entry.issue_id
        assert_equal 2, entry.user_id
        put '/imperator_api/v1/time_entries/1.json', {
          :time_entry => {:issue_id => '2',
                          :hours => '8'}}, credentials('admin')
        assert_response 200
        entry.reload
        assert_equal 8, entry.hours
        assert_equal 2, entry.issue_id
        assert_equal 2, entry.user_id
      end

      def test_bulk_update
        # update time entry activity
        post '/imperator_api/v1/time_entries/bulk_update.json', { 
          :ids => [1, 2], :time_entry => { :activity_id => 9}}, credentials('admin')
        assert_response 204
        # check that the issues were updated
        assert_equal [9, 9], TimeEntry.where(:id => [1, 2]).collect {|i| i.activity_id}
      end

      def test_bulk_update_with_failure
        post '/imperator_api/v1/time_entries/bulk_update.json', { 
          :ids => [1, 2], :time_entry => { :hours => 'A'}}, credentials('admin')
        assert_response 422
      end
      
      def test_destroy
        delete '/imperator_api/v1/time_entries/1.json', {}, credentials('admin')
        assert_response 200
        assert_nil TimeEntry.find_by_id(1)
      end

      def test_destroy_should_fail
        TimeEntry.any_instance.expects(:destroy).returns(false)
        delete '/imperator_api/v1/time_entries/1.json', {}, credentials('admin')
        assert_response 422
        assert_not_nil TimeEntry.find_by_id(1)
      end
    end
  end
end
