require 'test_helper'

# Re-raise errors caught by the controller.
class Api::UsersController; def rescue_action(e) raise e end; end

class Api::UsersControllerTest < ActionController::TestCase
  context "Users Controller" do
    setup do
      @controller = Api::UsersController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @zooniverse_user = Factory :zooniverse_user
    end
    
    context "#show when not logged in" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :show, { :id => @zooniverse_user.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#show when logged in as an api user" do
      setup do
        api_login
        get :show, { :id => @zooniverse_user.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "render XML correctly" do
        assert_select "user", 1
        assert_select "id", "#{ @zooniverse_user.id }"
        assert_select "classifications", "#{ @zooniverse_user.classifications.length }"
        assert_select "last_active_at", "#{ @zooniverse_user.last_active_at }"
        assert_select "last_classified", "#{ @zooniverse_user.last_classified }"
      end
    end
  end
end
