Redmine::Plugin.register :redmine_imperator do
  name 'Redmine Imperator plugin'
  author 'Marcin Kalita'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_imperator'
  author_url 'http://www.efigence.com/'

  settings default: {
    'base_url' => '',
    'api_key' => '2ce03d6ea21775217f0ef4b8e56ce51abf86977a34270147b78210dc24632eda20f2b26fea440953cdeb2cb0fd6b82cbe2254a48f2b5d916db48e9851d9200d0'
    }, partial: 'settings/imperator_settings'
end

ActionDispatch::Callbacks.to_prepare do
  ApplicationController.send(:include, ImperatorApi::Patches::ApplicationControllerPatch)
  ProjectsController.send(:include, ImperatorApi::Patches::ProjectsControllerPatch)
  UsersController.send(:include, ImperatorApi::Patches::UsersControllerPatch)
  MyController.send(:include, ImperatorApi::Patches::MyControllerPatch)
  GroupsController.send(:include, ImperatorApi::Patches::GroupsControllerPatch)
end
