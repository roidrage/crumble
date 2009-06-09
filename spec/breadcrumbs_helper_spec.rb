require File.dirname(__FILE__) + '/spec_helper'

require 'active_support'
require 'action_view/helpers/url_helper'

describe BreadcrumbsHelper do
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  attr_accessor :params
  
  def edit_account_url
    "http://test.host/account/edit"
  end
  
  def user_url(user)
    "http://test.host/f/#{user.login}"
  end
  
  def user_article_url(user, article)
    "http://test.host/f/#{user.login}/articles/#{article.id}"
  end
  
  def search_url(params)
    if params.is_a?(Hash)
      "http://test.host/search?#{params.collect{|key, value| "#{key.to_s}=#{value}"}.join('&')}"
    else
      "http://test.host/search/#{params}"
    end
  end
  
  User = Struct.new(:login)
  Article = Struct.new(:id)
  
  include BreadcrumbsHelper
  
  before(:each) do
    @params = {}
    @user = User.new("jonathan")
    @article = Article.new(1)
    Breadcrumb.configure do
      delimit_with " / "
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
      crumbs.should == %Q{<a href="http://test.host/search?country=Germany&amp;q=google">Search</a>}
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
