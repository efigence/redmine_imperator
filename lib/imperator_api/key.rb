# ImperatorApi::Key.new.show_secret
# ImperatorApi::Key.new.matches?('123qwe')
require 'yaml'
module ImperatorApi
  class Key
    class Secret
      def self.read_key_file
        File.read(File.expand_path(File.dirname(__FILE__) + '/../../../../config/settings.yml'))
      end

      def self.imperator_api_key
        YAML.load(read_key_file)[Rails.env]['imperator_api_key']['default']
      end

      TOKEN = imperator_api_key

      def to_s
        TOKEN
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
