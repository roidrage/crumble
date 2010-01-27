Crumble - It's like breadcrumbs for your Rails application!

It's a tiny combination of a helper and a simple configuration class to make breadcrumbs cool, because they're not.

Installation
============

The gem is hosted on gemcutter, so if you haven’t already, add it as a gem source:

    gem sources -a http://gemcutter.org/

Then install the Formtastic gem (recommended):

    gem install crumble

Alternatively you can also install it as a Rails plugin:

    script/plugin install git://github.com/mattmatt/crumble.git

Requires Rails 2.3.

Note: If you have configured Rails to reload all plugins in development mode, then putting your breadcrumbs configuration into an initializer won't work, since the classes, and therefore the breadcrumbs configuration will be unloaded after the request, and not be reloaded before the next one.

This will cause the problem. Either disable it, or let Rails use the default, which is to not reload plugins.

    config.reload_plugins = true

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

If you need to fetch a nested object from an existing one, you can do it with nested hashes, nesting knowing now boundaries, as long as a tree of objects conforming to them (in this case @user.blog.name) exists:

    crumb :blog, "Your Blog", :blog_url, :user => {:blog => :name}
    crumb :blog, "Your Blog", :blog_url, :user => :blog

If you really need to (only if you really, really need to), you can specify a string to be eval'd at runtime as parameter for the URL method. Brace yourself, it's not pretty:

    crumb :blog, "Your Blog", :blog_url, '@user.blog'

You can also add URL parameters derived from the parameters of the current request:

    crumb :search, "Search", :new_search_url, :params => :q

Arrays of parameters work too:

    crumb :search, "Search", :new_search_url, :params => [:q, :country]

And nested parameters:

    crumb :search, "Search", :new_search_url, :params => {:search => :q}

If you want to make the link title content dynamic, just use single quotes and rely on interpolation, you just need to ensure the interpolated code exists in the context of your helpers:

    crumb :search, 'Search (Keywords: #{params[:q]})', :new_search_url, :params => :q

If you don't want to specify any URL method at all, just use :current, it'll just use all the parameters of the current action, of course being aware that you can't have an URL method called current to rely on. But who would do that anyway?

    crumb :search, 'Search (Keywords: #{params[:q]})', :current

Internationalization usage

For example, if you want to localize your menu, define a new breadcrumbs node in your .yml file with all the keys for your elements.
    # config/locales/en.yml
    en:
      breadcrumbs:
        homepage: Homepage
        profile: Your Profile
        profile_dynamic: Hi {{name}}

    # config/locales/es.yml
    es:
      breadcrumbs:
        homepage: Homepage
        profile: Tu perfil
        profile_dynamic: Hola {{name}}

Then you can define the title of your crum as:

     crumb :profile, nil, :account_url

Crumble find your locale for the scope "breadcrumbs.#{crumb.name}"

If you want to make the I18n title content dynamic, just use a hash with the same key as the i18n param and with a hash value that will be interpolate to @user.name in this case:

      crumb :profile_dynamic, {:name => {:user => :name}}, :account_url

You can base trails on conditions using :unless and :if. Both need to point to a method that exists in the context of the view.

    trail :home, :index, [:root], :unless => :logged_in?
    trail :home, :index, [:your_account], :if => :logged_in?

Alternatively you can specify a block that takes the controller as an argument.

    trail :home, :index, [:your_account], :if => lambda {|controller| controller.logged_in?}

Your trails can also relate to a bunch of actions, just specify an array instead.

    trail :profiles, [:show, :edit], [:profile]

To keep your breadcrumbs definition neat and tidy, wrap them based on their context with a handy method called, you guessed it, context:

    context "user profile" do
      trail :home, :index, [:root], :unless => :logged_in?
      trail :home, :index, [:your_account], :if => :logged_in?
    end

Dump your trails and crumbs in there and bask in the glory of an easier readable crumbs definition.

If you don't want to have the last crumb linked, no problem at all, we can do that too:

    Breadcrumb.configure do
      dont_link_last_crumb
    end

Yep, that's it. Include that in your breadcrumbs definition and you're done.
Then, in your views, just insert the following:

    <%= crumbs %>

Don't forget to include the helper in the affected controllers:

    class ApplicationController < ActionController::Base
        helper :breadcrumbs
    end

If your trails reference non-existing crumbs, the plugin will raise an error telling you where in your configuration the illegal reference was made.

Future
======

If you think something's missing, let me know at <meyer@paperplanes.de>, or even better, send patches, including tests.

Contributors
===========

* Paco Guzmán (i18n support)

License
=======

MIT

(c) 2009 [Mathias Meyer](http://www.paperplanes.de)
