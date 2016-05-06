require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

module ImperatorApi
  class KeyTest < ActiveSupport::TestCase

    def test_show_secret
      key = ImperatorApi::Key.new.show_secret
      assert_kind_of String, key
      assert_match '2ce03d6ea21775217f0ef4b8e56ce51abf86977a34270147b78210dc24632eda20f2b26fea440953cdeb2cb0fd6b82cbe2254a48f2b5d916db48e9851d9200d0', key
    end

    def test_matches
      key = '2ce03d6ea21775217f0ef4b8e56ce51abf86977a34270147b78210dc24632eda20f2b26fea440953cdeb2cb0fd6b82cbe2254a48f2b5d916db48e9851d9200d0'
      assert ImperatorApi::Key.new.matches?(key)
    end
  end
end
