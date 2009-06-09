Crumble - It's like breadcrumbs for your Rails application!

It's a tiny combination of a helper and a simple configuration class to make breadcrumbs cool, because they're not.

Installation
============

    script/plugin install git://github.com/mattmatt/crumble.git

Requires Rails 2.3.

Usage
=====

I wanted to have a rather simple API to configure breadcrumbs, so I made one. Basically you configure your breadcrumbs in an initializers, e.g. config/initializers/breadcrumbs.rb like so:

    Breadcrumb.configure do
      # Specify name, link title and the URL to link to
      crumb :profile, "Your Profile", :account_url
      crumb :root, "Home", :root_url
      
      # Specify controller, action, and an array of the crumbs you specified above
      trail :accounts, :show, [:root, :profile]
      trail :home, :index, [:root]
      
      # Specify the delimiter for the crumbs
      delimit_with "/"
    end

You can hand over parameters to the URL generator methods, the parameters are expected to exist as instance variables in your controller/helper:

    crumb :blog_comment, "Your Profile", :blog_comment_url, :blog, :comment

You can also add URL parameters derived from the parameters of the current request:

    crumb :search, "Search", :new_search_url, :params => :q

Arrays of parameters work too:

    crumb :search, "Search", :new_search_url, :params => [:q, :country]

And nested parameters:

    crumb :search, "Search", :new_search_url, :params => {:search => :q}

If you want to make the link title content dynamic, just use single quotes and rely on interpolation, you just need to ensure the interpolated code exists in the context of your helpers:

    crumb :search, 'Search (Keywords: #{params[:q]})', :new_search_url, :params => :q
Then, in your views, just insert the following:

    <%= crumbs %>
    
License
=======

MIT

(c) 2009 [Mathias Meyer](http://www.paperplanes.de)