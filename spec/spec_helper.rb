require 'rubygems'
gem 'rspec'

require "#{File.dirname(__FILE__)}/../app/helpers/breadcrumbs_helper"
require "#{File.dirname(__FILE__)}/../lib/breadcrumb"

Spec::Runner.configure do |config|

  config.before(:each) do
    @old_trails = Breadcrumb.instance.trails
    Breadcrumb.instance.trails = nil
  
    @old_crumbs = Breadcrumb.instance.crumbs
    Breadcrumb.instance.crumbs = nil
  end
  
  config.after(:each) do
    Breadcrumb.instance.crumbs = @old_crumbs
    Breadcrumb.instance.trails = @old_trails
  end
end
