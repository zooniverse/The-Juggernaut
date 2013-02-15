require 'test_helper'

# Re-raise errors caught by the controller.
class Public::UsersController; def rescue_action(e) raise e end; end

class Public::UsersControllerTest < ActionController::TestCase
  context "Public Users Controller" do
    setup do
      @controller = Public::UsersController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @zooniverse_user = Factory :zooniverse_user, :api_key => "1234"
    end
    
    context "When querying a User's own details" do
      setup do
        get :show, { :id => @zooniverse_user.id, :user_id => @zooniverse_user.id, :api_key => @zooniverse_user.api_key, :format => :xml }
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
    
    context "When querying another User's details" do
      setup do
        get :show, { :id => "123", :user_id => "123", :api_key => @zooniverse_user.api_key, :format => :xml }
      end
      
      should respond_with :forbidden
      should respond_with_content_type :xml
    end
    
    context "When querying a User's own details but with the wrong API key" do
      setup do
        get :show, { :id => @zooniverse_user.id, :api_key => "blah", :format => :xml }
      end
      
      should respond_with :forbidden
      should respond_with_content_type :xml
    end
  end
end
