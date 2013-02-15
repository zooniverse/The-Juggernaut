require 'test_helper'

# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < ActionController::TestCase
  context "Home controller" do
    setup do
      @controller = HomeController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "#index not logged in" do
      setup do
        get :index
      end
      
      should respond_with :redirect
      should redirect_to('CAS Gateway'){ @controller.cas_login :gateway => 'true' }
    end
    
    context "#index when logged in" do
      setup do
        standard_cas_login
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
    
    context "When cookie has CAS ticket details" do
      setup do
        standard_cas_login
        get :index
      end
      
      should set_session(:cas_user) { "arfon" }
      
      should "have convenience methods for cas_user, cas_user_id and cas_api_key" do
        assert_equal @user.name, @controller.zooniverse_user
        assert_equal @user.id, @controller.zooniverse_user_id
        assert_equal @user.api_key, @controller.zooniverse_user_api_key
      end
    end
    
    context "When accessing the profile when not logged in" do
      setup do
        get :profile
      end
      
      should respond_with :redirect
      should redirect_to('CAS Login') { "#{ @controller.cas_login }profile" }
    end
    
    context "When accessing the profile and user IS logged in" do
      setup do
        standard_cas_login
        get :profile
      end
      
      should respond_with :success
      should render_template :profile
      should assign_to(:user).with_kind_of(ZooniverseUser)
      should assign_to :recents
      should assign_to :favourites
    end
  end
end
