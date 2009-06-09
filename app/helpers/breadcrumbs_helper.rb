module BreadcrumbsHelper
  def crumbs
    (Breadcrumb.instance.trails || []).each do |condition, trail|
      if condition[:controller].to_sym == params[:controller].to_sym and
        condition[:action].to_sym == params[:action].to_sym
        return calculate_breadcrumb_trail(trail)
      end
    end
    ""
  end
  
  def calculate_breadcrumb_trail(trail)
    breadcrumb_trail = []
    trail.each do |crumb|
      crumb_detail = Breadcrumb.instance.crumbs[crumb]
      breadcrumb_trail << link_to(eval(%Q{"#{crumb_detail[0]}"}), fetch_crumb_url(crumb_detail))
    end
    breadcrumb_trail.join(Breadcrumb.instance.delimiter)
  end
  
  def fetch_parameterized_crumb_url(crumb)
    case crumb[2]
    when Hash
      send(crumb[1], fetch_parameters_recursive(crumb[2][:params]))
    else
      send(crumb[1], *crumb[2].collect {|name| instance_variable_get("@#{name}")})
    end
  end
  
  def fetch_crumb_url(crumb)
    if crumb[2]
      fetch_parameterized_crumb_url(crumb)
    else
      url = send(crumb_detail[1])
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
end