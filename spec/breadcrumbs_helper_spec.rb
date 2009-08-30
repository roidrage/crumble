require File.dirname(__FILE__) + '/spec_helper'

require 'active_support'
require 'action_view/helpers/url_helper'

describe BreadcrumbsHelper do
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include BreadcrumbsHelper

  attr_accessor :params
  
  def controller
    self
  end
  
  before(:each) do
    @params = {}
    @user = User.new("jonathan")
    @article = Article.new(1)
    Breadcrumb.configure do
      delimit_with " / "
      link_last_crumb
    end
  end
  
  describe "when getting the breadcrumbs" do
    before(:each) do
    end
    
    it "should calculate the urls in the breadcrumbs" do
      Breadcrumb.configure do
        crumb :your_account, "Your Account", :edit_account_url
        trail :accounts, :index, [:your_account]
      end
      params[:controller] = 'accounts'
      params[:action] = 'index'
      crumbs.should == %Q{<a href="http://test.host/account/edit">Your Account</a>}
    end
    
    it "should support fetching an instance variable" do
      Breadcrumb.configure do
        crumb :profile, "Public Profile", :user_url, :user
        trail :accounts, :edit, [:profile]
      end
      params[:controller] = 'accounts'
      params[:action] = 'edit'
      crumbs.should == %Q{<a href="http://test.host/f/jonathan">Public Profile</a>}
    end
    
    it "should support fetching multiple instance variables" do
      Breadcrumb.configure do
        trail :accounts, :profile, [:your_article]
        crumb :your_article, "Your Article", :user_article_url, :user, :article
      end
        
      params[:controller] = 'accounts'
      params[:action] = 'profile'
      crumbs.should == %Q{<a href="http://test.host/f/jonathan/articles/1">Your Article</a>}
    end
    
    it "should join multiple crumbs with a /" do
      Breadcrumb.configure do
        trail :accounts, :show, [:profile, :your_account]
        crumb :profile, "Public Profile", :user_url, :user
        crumb :your_account, "Your Account", :edit_account_url
      end
      
      params[:controller] = 'accounts'
      params[:action] = 'show'
      crumbs.should == %Q{<a href="http://test.host/f/jonathan">Public Profile</a> / <a href="http://test.host/account/edit">Your Account</a>}
    end
    
    it "should return an empty string for no matches" do
      Breadcrumb.configure do
      end
      params[:controller] = 'accounts'
      params[:action] = 'sho'
      crumbs.should == ""
    end
    
    it "should add parameters to the url" do
      Breadcrumb.configure do
        crumb :search, "Search", :search_url, :params => :q
        trail :search, :new, [:search]
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      params[:q] = 'google'
      crumbs.should == %Q{<a href="http://test.host/search?q=google">Search</a>}
    end
    
    it "should add multiple parameters to the url" do
      Breadcrumb.configure do
        crumb :search, "Search", :search_url, :params => [:q, :country]
        trail :search, :new, [:search]
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      params[:country] = 'Germany'
      params[:q] = 'google'
      crumbs.should == %Q{<a href="http://test.host/search?q=google&amp;country=Germany">Search</a>}
    end
    
    it "should eval single quoted title strings and interpolate them" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results (#{@query})', :search_url, :query
        trail :search, :create, [:search_results]
      end
      
      params[:controller] = 'search'
      params[:action] = 'create'

      @query = 'google'
      crumbs.should == %Q{<a href="http://test.host/search/google">Search Results (google)</a>}
    end
    
    it "should support a list of actions to configure a trail" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results (#{@query})', :search_url
        trail :search, [:create, :new], [:search_results]
      end
      
      params[:controller] = 'search'
      params[:action] = 'create'
      crumbs.should == %Q{<a href="http://test.host/search/">Search Results ()</a>}
      
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/">Search Results ()</a>}
    end
    
    it "should support using the current url instead of a predefined one" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results (#{@query})', :current
        trail :search, [:create, :new], [:search_results]
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/new">Search Results ()</a>}
    end
    
    it "should not consider a trail when it has an :if condition and it's not met" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :current
        trail :search, [:create, :new], [:search_results], :if => :is_it_false?
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == ""
    end

    it "should consider a trail when it has an :if condition and it's met" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :current
        trail :search, [:create, :new], [:search_results], :if => :its_true!
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/new">Search Results</a>}
    end

    it "should not consider a trail when it has an :unless condition and it's not met" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :current
        trail :search, [:create, :new], [:search_results], :unless => :its_true!
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == ""
    end

    it "should consider a trail when it has an :unless condition and it's met" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :current
        trail :search, [:create, :new], [:search_results], :unless => :is_it_false?
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/new">Search Results</a>}
    end
    
    it "should call blocks as :unless parameters" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :current
        trail :search, [:create, :new], [:search_results], :unless => lambda {|controller| controller.its_true!}
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == ""
    end

    it "should call blocks as :if parameters" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :current
        trail :search, [:create, :new], [:search_results], :if => lambda {|controller| controller.its_true!}
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == "<a href=\"http://test.host/search/new\">Search Results</a>"
    end
    
    it "should support resolving parameters for url methods derived from a string" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :search_url, "@user.login"
        trail :search, [:create, :new], [:search_results]
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/jonathan">Search Results</a>}
    end

    it "should support resolving parameters for url methods derived from a hash pointing to an object hierarchy" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :search_url, :user => :login
        trail :search, [:create, :new], [:search_results]
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/jonathan">Search Results</a>}
    end

    it "should support resolving parameters for url methods derived from a hash pointing to a nested object hierarchy" do
      Breadcrumb.configure do
        crumb :search_results, 'Search Results', :search_url, :user => {:login => :to_s}
        trail :search, [:create, :new], [:search_results]
      end
      
      params[:controller] = 'search'
      params[:action] = 'new'
      crumbs.should == %Q{<a href="http://test.host/search/jonathan">Search Results</a>}
    end
    
    it "should return the same breadcrumbs on subsequent calls" do
      Breadcrumb.configure do
        crumb :your_account, "Your Account", :edit_account_url
        trail :accounts, :index, [:your_account]
      end
      params[:controller] = 'accounts'
      params[:action] = 'index'
      once = crumbs
      twice = crumbs
      once.should == twice
    end
    
    it "should not link the last link when the option was specified" do
      Breadcrumb.configure do
        trail :accounts, :show, [:profile, :your_account]
        crumb :profile, "Public Profile", :user_url, :user
        crumb :your_account, "Your Account", :edit_account_url
        dont_link_last_crumb
      end
      
      params[:controller] = 'accounts'
      params[:action] = 'show'
      crumbs.should == %Q{<a href="http://test.host/f/jonathan">Public Profile</a> / Your Account}
    end

    it "should not link the last link when the option was specified and only one crumb is in the trail" do
      Breadcrumb.configure do
        trail :accounts, :show, [:profile]
        crumb :profile, "Public Profile", :user_url, :user
        dont_link_last_crumb
      end
      
      params[:controller] = 'accounts'
      params[:action] = 'show'
      crumbs.should == %Q{Public Profile}
    end
    
    describe "when fetching parameters" do
      it "should support nested parameter attributes" do
        Breadcrumb.configure do
          crumb :nested_search, "Search", :search_url, :params => {:search => :q}
          trail :search, :new, [:nested_search]
        end
      
        params[:controller] = "search"
        params[:action] = 'new'
        params[:search] = {:q => "google", :country => "Germany"}
      
        fetch_parameters_recursive({:search => [:q, :country]}).should == {:search => {:q => "google", :country => "Germany"}}
      end
      
      it "should support nested array parameters" do
        Breadcrumb.configure do
          crumb :nested_search, "Search", :search_url, :params => {:search => :q}
          trail :search, :new, [:nested_search]
        end

        params[:controller] = "search"
        params[:action] = 'new'
        params[:search] = {:q => "google", :country => ["Germany", "Australia"]}

        fetch_parameters_recursive({:search => [:q, :country]}).should == {:search => {:q => "google", :country => ["Germany", "Australia"]}}
      end

      it "should not include empty parameters" do
        Breadcrumb.configure do
          crumb :nested_search, "Search", :search_url, :params => {:search => :q}
          trail :search, :new, [:nested_search]
        end

        params[:controller] = "search"
        params[:action] = 'new'
        params[:search] = {:q => ""}

        fetch_parameters_recursive({:search => [:q, :country]}).should == {:search => {}}
      end
      
      it "should not include empty parameters with nested hashes" do
        Breadcrumb.configure do
          crumb :nested_search, "Search", :search_url, :params => {:search => :q}
          trail :search, :new, [:nested_search]
        end

        params[:controller] = "search"
        params[:action] = 'new'
        params[:search] = {:q => "google", :country => []}

        fetch_parameters_recursive({:search => [:q, :country]}).should == {:search => {:q => "google"}}
      end
    end
  end
end
