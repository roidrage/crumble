require File.dirname(__FILE__) + '/spec_helper'

describe Breadcrumb do
  describe "when configuring the instance" do
    it "should add trails" do
      Breadcrumb.configure do
        trail :accounts, :edit, [:profile, :your_account]
      end
      
      Breadcrumb.instance.trails.last.should == [{:controller => :accounts, :action => :edit}, [:profile, :your_account]]
    end
    
    it "should add crumbs" do
      Breadcrumb.configure do
        crumb :profile, "Public Profile", :user_url, :user
      end
      
      Breadcrumb.instance.crumbs[:profile].should == ["Public Profile", :user_url, [:user]]
    end
    
    it "should store the delimiter" do
      Breadcrumb.configure do
        delimit_with "/"
      end
      
      Breadcrumb.instance.delimiter.should == "/"
    end
  end
end