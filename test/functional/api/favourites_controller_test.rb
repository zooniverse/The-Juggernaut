require 'test_helper'

# Re-raise errors caught by the controller.
class Api::FavouritesController; def rescue_action(e) raise e end; end

class Api::FavouritesControllerTest < ActionController::TestCase
  context "Favourites controller" do
    setup do
      @controller = Api::FavouritesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @zooniverse_user = Factory :zooniverse_user
      @subject = Factory :subject
      @favourite = Factory :favourite, :subject => @subject, :zooniverse_user => @zooniverse_user
    end
    
    context "#index not logged in without SSL" do
      setup do
        get :index, { :format => :xml }
      end
      
      should respond_with :redirect
    end
    
    context "#index not logged in with SSL" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :index, { :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#index logged in without a user_id or an subject_id" do
      setup do
        api_login
        get :index, { :format => :xml }
      end
      
      should respond_with :forbidden
    end
    
    context "#index not logged in passing a user_id" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :index, { :user_id => @zooniverse_user.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#index logged in passing a user_id" do
      setup do
        api_login
        get :index, { :user_id => @zooniverse_user.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "return valid XML" do
        assert_select "favourites", 1
        assert_select "favourite", 1
        assert_select "subject_id", "#{ @subject.id }"
        assert_select "subject_location", "#{ @subject.location }"
        assert_select "external_ref", "#{ @subject.external_ref }"
      end
    end
    
    context "#index logged in passing a user_id and a page" do
      setup do
        api_login
        get :index, { :user_id => @zooniverse_user.id, :page => 2, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
    end
    
    context "#index not logged in passing a subject_id" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :index, { :subject_id => @subject.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#index logged in passing a subject_id" do
      setup do
        api_login
        get :index, { :subject_id => @subject.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
    end
    
    context "#index logged in passing a subject_id and a page" do
      setup do
        api_login
        get :index, { :subject_id => @subject.id, :page => 2, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
    end
    
    context "#index logged in passing a date range" do
      setup do
        api_login
        
        Factory :favourite, :subject => @subject, :zooniverse_user => @zooniverse_user, :created_at => 2.days.ago
        @favourite2 = Factory :favourite, :subject => @subject, :zooniverse_user => @zooniverse_user
        
        get :index, { :subject_id => @subject.id, :from => 1.day.ago.utc, :to => 1.day.from_now.utc, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "find favourites in the date range" do
        assert_select "favourite" do |favourite|
          assert_select "id", /#{ @favourite.id }|#{ @favourite2.id }/
        end
      end
    end
    
    context "#show not logged in" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :show, { :id => @favourite.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#show logged in as an api user" do
      setup do
        api_login
        get :show, { :id => @favourite.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "return valid XML" do
        assert_select "favourite", 1
        assert_select "id", "#{ @favourite.id }"
        assert_select "created_on", "#{ @favourite.created_at }"
        assert_select "subject_id", "#{ @favourite.subject.id }"
        assert_select "subject_location", "#{ @favourite.subject.location }"
      end
    end
    
    context "#create" do
      setup do
        api_login
        
        @new_subject = Factory :subject
        options = {
          :favourite => {
            :zooniverse_user_id => @zooniverse_user.id,
            :subject_id => @new_subject.id
          },
          :format => :xml
        }
        
        post :create, options
      end
      
      should respond_with :created
      
      should "create a favourite successfully" do
        favourite = Favourite.find_by_zooniverse_user_id_and_subject_id @zooniverse_user.id, @new_subject.id
        assert favourite
        assert_equal "https://test.host/api/favourites/#{ favourite.id }", @response.header['Location']
      end
    end
    
    context "#destroy" do
      setup do
        api_login
        post :destroy, :id => @favourite.id, :format => :xml
      end
      
      should respond_with :success
      should "decrease the number of user favourites by 1" do
        assert_equal 0, Favourite.count
      end
    end
  end
end
