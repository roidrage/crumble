require File.dirname(__FILE__) + '/spec_helper'

describe Breadcrumb do
  describe "when configuring the instance" do
    it "should add trails" do
      Breadcrumb.configure do
        crumb :profile, "Public Profile", :user_url, :user
        crumb :your_account, "Public Profile", :user_url, :user
        
        trail :accounts, :edit, [:profile, :your_account]
      end
      
      trail = Breadcrumb.instance.trails.last
      trail.controller.should == :accounts
      trail.action.should == :edit
      trail.trail.should == [:profile, :your_account]
    end
    
    it "should add crumbs" do
      Breadcrumb.configure do
        crumb :profile, "Public Profile", :user_url, :user
      end
      
      profile = Breadcrumb.instance.crumbs[:profile]
      profile.title.should == "Public Profile"
      profile.url.should == :user_url
      profile.params.should == [:user]
    end
    
    it "should store the delimiter" do
      Breadcrumb.configure do
        delimit_with "/"
      end
      
      Breadcrumb.instance.delimiter.should == "/"
    end
    
    it "should set the flag not to link the last crumb" do
      Breadcrumb.configure do
        dont_link_last_crumb
      end
      
      Breadcrumb.instance.last_crumb_linked?.should == false
    end

    it "should unset the flag not to link the last crumb" do
      Breadcrumb.configure do
        link_last_crumb
      end
      
      Breadcrumb.instance.last_crumb_linked?.should == true
    end
    
    it "should support contexts" do
      Breadcrumb.configure do
        context "user profile" do
          crumb :profile, "Public Profile", :user_url, :user
        end
      end
      
      profile = Breadcrumb.instance.crumbs[:profile]
      profile.title.should == "Public Profile"
      profile.url.should == :user_url
      profile.params.should == [:user]
    end
    
    it "should not accept non-existing trails in crumb definitions" do
      lambda {
        Breadcrumb.configure do
          trail :accounts, :edit, [:profile]
        end
      }.should raise_error(RuntimeError, "Trail for accounts/edit references non-existing crumb 'profile' (configuration file line: 70)")
    end
    
    it "should include errors for multiple missing crumb definitions" do
      lambda {
        Breadcrumb.configure do
          trail :accounts, :edit, [:profile]
          trail :accounts, :show, [:profile]
        end
      }.should raise_error(RuntimeError, "Trail for accounts/edit references non-existing crumb 'profile' (configuration file line: 78)\nTrail for accounts/show references non-existing crumb 'profile' (configuration file line: 79)")
    end
  end
end