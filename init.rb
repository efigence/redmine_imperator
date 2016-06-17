Redmine::Plugin.register :redmine_imperator do
  name 'Redmine Imperator plugin'
  author 'Marcin Kalita'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_imperator'
  author_url 'http://www.efigence.com/'

  settings default: { 'base_url' => '', 'redirecitons' => '' },
           partial: 'settings/imperator_settings'
end

ActionDispatch::Callbacks.to_prepare do
  ApplicationController.send(:include, ImperatorApi::Patches::ApplicationControllerPatch)
  ProjectsController.send(:include, ImperatorApi::Patches::ProjectsControllerPatch)
  UsersController.send(:include, ImperatorApi::Patches::UsersControllerPatch)
  MyController.send(:include, ImperatorApi::Patches::MyControllerPatch)
  GroupsController.send(:include, ImperatorApi::Patches::GroupsControllerPatch)
end
