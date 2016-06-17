require_dependency 'application_controller'

module ImperatorApi
  module Patches
    module ApplicationControllerPatch
      extend ActiveSupport::Concern

      included do
        unloadable

        before_filter :fetch_redirects
        before_filter :redirect_if_needed
      end

      def redirect_if_needed
        redirect_to(fetch_path) if redirectable?
      end

      def redirectable?
        return false unless @controllers.include? params[:controller]
        @controllers[params[:controller]].keys.include? params[:action]
      end

      def fetch_redirects
        redirects_path = File.expand_path(
          File.join(File.dirname(__FILE__), '../../../config/redirects.yml')
        )
        @controllers = YAML.load(File.read(redirects_path))
      rescue Psych::SyntaxError, Errno::ENOENT
        @controllers = {}
      end

      def fetch_path
        h = @controllers[params[:controller]][params[:action]]
        h.key?('url') ? h['url'] : build_new_path(h['path'])
      end

      def build_new_path(pattern)
        if pattern == 'default'
          path = request.path
        else
          keys = params.symbolize_keys
          path = pattern % keys
        end
        Setting.plugin_redmine_imperator['base_url'] + path + '#redmine'
      end
    end
  end
end
