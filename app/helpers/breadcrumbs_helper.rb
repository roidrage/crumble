module BreadcrumbsHelper
  def crumbs
    (Breadcrumb.instance.trails || []).each do |trail|
      if trail.controller.to_sym == params[:controller].to_sym and
        trail.action.to_sym == params[:action].to_sym
        next unless trail.condition_met?(self)
        return calculate_breadcrumb_trail(trail.trail)
      end
    end
    ""
  end
  
  def calculate_breadcrumb_trail(trail)
    breadcrumb_trail = []
    trail.each do |crummy|
      crumb = Breadcrumb.instance.crumbs[crummy]
      if not Breadcrumb.instance.last_crumb_linked? and crummy == trail.last
        breadcrumb_trail << eval(%Q{"#{crumb.title}"})
      else
        breadcrumb_trail << link_to(eval(%Q{"#{crumb.title}"}), fetch_crumb_url(crumb))
      end
    end
    breadcrumb_trail.join(Breadcrumb.instance.delimiter)
  end
  
  def fetch_parameterized_crumb_url(crumb)
    case crumb.params
    when Hash
      if crumb.params[:params]
        send(crumb.url, fetch_parameters_recursive(crumb.params[:params]))
      else
        result = instance_eval("@#{assemble_crumb_url_parameter(crumb.params).join(".")}")
        send(crumb.url, result)
      end
    else
      if crumb.url == :current
        params
      else
        prams = crumb.params.collect do |name|
          case name
          when Symbol
            instance_variable_get("@#{name}")
          when String
            instance_eval(name)
          end
        end
        send(crumb.url, *prams)
      end
    end
  end
  
  def fetch_crumb_url(crumb)
    if crumb.params
      fetch_parameterized_crumb_url(crumb)
    else
      send(crumb.url)
    end
  end
  
  def fetch_parameters_recursive(params_hash, parent = nil)
    parameters = {}
    case params_hash
    when Symbol
      parameters[params_hash] = (parent || params)[params_hash]
    when Array
      params_hash.each do |pram|
        parameter = (parent || params)[pram]
        parameters[pram] = parameter unless parameter.blank?
      end
    when Hash
      params_hash.each do |pram, nested|
        parameters[pram] = fetch_parameters_recursive(nested, params[pram])
      end
    end
    parameters
  end
  
  def assemble_crumb_url_parameter(params)
    result = []
    params.to_a.flatten.collect do |step|
      result << if step.is_a?(Hash)
        assemble_crumb_url_parameter(step)
      else
        step
      end
    end
    result
  end
end