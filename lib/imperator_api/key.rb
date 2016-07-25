# ImperatorApi::Key.new.show_secret
# ImperatorApi::Key.new.matches?('123qwe')
module ImperatorApi
  class Key
    class Secret
      def to_s
        Setting.plugin_redmine_imperator['api_key']
      end
    end
    private_constant :Secret

    def show_secret
      Secret.new.to_s
    end

    def matches?(key)
      !key.nil? && key.to_s == show_secret
    end
  end
end
