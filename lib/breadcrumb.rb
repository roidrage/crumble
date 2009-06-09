require 'singleton'

class Breadcrumb
  include Singleton
  attr_accessor :trails, :crumbs, :delimiter
  
  def self.configure(&blk)
    instance.instance_eval &blk
  end
  
  def trail(controller, action, trail)
    @trails ||= []
    @trails << [{:controller => controller, :action => action}, trail]
  end
  
  def crumb(name, title, url, *params)
    params = params.first if params.any? && params.first.is_a?(Hash)
    @crumbs ||= {}
    @crumbs[name] = [title, url, params]
  end
  
  def delimit_with(delimiter)
    @delimiter = delimiter
  end
end