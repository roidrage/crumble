require 'singleton'

class Breadcrumb
  include Singleton
  Trail = Struct.new(:controller, :action, :trail, :options) do
    def condition_met?
      options[:if].nil? or (options[:if] and options[:if].call)
    end
  end
  
  Crumb = Struct.new(:name, :title, :url, :params)
  
  attr_accessor :trails, :crumbs, :delimiter
  
  def self.configure(&blk)
    instance.instance_eval &blk
  end
  
  def trail(controller, actions, trail, options = {})
    @trails ||= []
    actions = Array(actions)
    actions.each do |action|
      @trails << Trail.new(controller, action, trail, options)
    end
  end
  
  def crumb(name, title, url, *params)
    params = params.first if params.any? && params.first.is_a?(Hash)
    @crumbs ||= {}
    @crumbs[name] = Crumb.new(name, title, url, params)
  end
  
  def delimit_with(delimiter)
    @delimiter = delimiter
  end
end