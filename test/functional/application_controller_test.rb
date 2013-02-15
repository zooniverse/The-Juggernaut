require 'test_helper'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < ActionController::TestCase
  context "Application controller" do
    should filter_param :password
    
    setup do
      @controller = ApplicationController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "When passed an invalid looking session" do
      setup do
        @session = Hash.new
      end
      
      should "not return #session_valid" do
        assert !@controller.session_valid?(@session)
      end
    end
    
    context "When passed an empty session" do
      setup do
        @session = Array.new
      end
      
      should "not return #session_valid" do
        assert !@controller.session_valid?(@session)
      end
    end
    
    context "When passed an empty session" do
      setup do
        @session = [1,2,3]
      end
      
      should "return #session_valid" do
        assert @controller.session_valid?(@session)
      end
    end
    
    context "When logged in" do
      setup do
        @zooniverse_user = Factory :zooniverse_user
        standard_cas_login(@zooniverse_user)
      end

      should "set session vars" do
        assert_equal @zooniverse_user.name, @request.session[:cas_user]
        assert_equal @zooniverse_user.zooniverse_user_id, @request.session[:cas_extra_attributes]['id']
        assert_equal @zooniverse_user.api_key, @request.session[:cas_extra_attributes]['api_key']
      end
    end
    
    context "When logging out" do
      setup do
        @zooniverse_user = Factory :zooniverse_user
        standard_cas_login(@zooniverse_user)
        get :cas_logout
      end

      should "reset the CAS session" do
        assert @request.session[:cas_user].nil?
        assert @request.session[:cas_extra_attributes].nil?
      end
    end
  end
end
