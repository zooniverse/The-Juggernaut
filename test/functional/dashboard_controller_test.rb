require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  context "Dashboard Controller" do
    setup do
      @controller = DashboardController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "When trying to access #index as a standard user" do
      setup do
        @zooniverse_user = Factory :zooniverse_user, :admin => false
        standard_cas_login(@zooniverse_user)
        get :index
      end

      should respond_with :redirect
    end
    
    context "When trying to access #index as an admin user" do
      setup do
        @zooniverse_user = Factory :zooniverse_user, :admin => true
        admin_cas_login(@zooniverse_user)
        get :index
      end

      should respond_with :success
      should render_template :index
    end
  end
end
