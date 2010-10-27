module Crumble
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'breadcrumbs_helper.include_to_action_controller' do
        require File.expand_path(File.dirname(__FILE__) + '/../../app/helpers/breadcrumbs_helper')
        ActionController::Base.helper(BreadcrumbsHelper)
      end
    end
  end
end
