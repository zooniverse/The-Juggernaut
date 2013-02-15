require 'test_helper'

# Re-raise errors caught by the controller.
class Public::FavouritesController; def rescue_action(e) raise e end; end

class Public::FavouritesControllerTest < ActionController::TestCase
  context "Public Favourites Controller" do
    setup do
      @controller = Public::FavouritesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @subject = Factory :subject
      @zooniverse_user = Factory :zooniverse_user, :api_key => "1234"
      @favourite_1 = Factory :favourite, :zooniverse_user => @zooniverse_user, :subject => @subject
      @favourite_2 = Factory :favourite, :zooniverse_user => @zooniverse_user, :subject => @subject
    end
    
    context "When querying a User's own favourites" do
      setup do
        get :index, :user_id => @zooniverse_user.id, :api_key => @zooniverse_user.api_key, :format => :xml
      end
      
      should respond_with :success
      should respond_with_content_type :xml
    end
    
    context "When querying a User's favourites passing a date range" do
      setup do
        Factory :favourite, :subject => @subject, :zooniverse_user => @zooniverse_user, :created_at => 2.days.ago
        get :index, :user_id => @zooniverse_user.id, :api_key => @zooniverse_user.api_key, :from => 1.day.ago.utc, :to => 1.day.from_now.utc, :format => :xml
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "find favourites in the date range" do
        assert_select "favourite" do |favourite|
          assert_select "id", /#{ @favourite_1.id }|#{ @favourite_2.id }/
        end
      end
    end
    
    context "When querying another User's favourites" do
      setup do
        get :index, :user_id => "123", :api_key => @zooniverse_user.api_key, :format => :xml
      end
      
      should respond_with :forbidden
      should respond_with_content_type :xml
    end
    
    context "When querying a User's own favourites but with the wrong API key" do
      setup do
        get :index, :user_id => @zooniverse_user.id, :api_key => "blah", :format => :xml
      end
      
      should respond_with :forbidden
      should respond_with_content_type :xml
    end
    
    context "When querying an Atom feed of a User's own favourites" do
      setup do
        get :index, :user_id => @zooniverse_user.id, :api_key => @zooniverse_user.api_key, :format => :atom
      end
      
      should respond_with :success
      should respond_with_content_type :atom
      
      should "return a valid atom feed" do
        assert_select "feed", 1
        assert_select "entry", 2
        assert_select "entry" do |favourite|
          assert_select "id", /Favourite\/#{ @favourite_1.id }|#{ @favourite_2.id }/
        end
      end
    end
    
    context "#show" do
      setup do
        get :show, :user_id => @zooniverse_user.id, :api_key => @zooniverse_user.api_key, :id => @favourite_1.id, :format => :xml
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "return valid XML" do
        assert_select "favourite", 1
        assert_select "id", "#{ @favourite_1.id }"
        assert_select "created_on", "#{ @favourite_1.created_at }"
        assert_select "subject_id", "#{ @favourite_1.subject.id }"
        assert_select "subject_location", "#{ @favourite_1.subject.location }"
      end
    end
    
    context "#create" do
      setup do
        @new_subject = Factory(:subject)
        options = {
          :user_id => @zooniverse_user.id,
          :api_key => @zooniverse_user.api_key,
          :favourite => {
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
        assert_equal "http://test.host/public/favourites/#{ favourite.id }", @response.header['Location']
      end
    end
    
    context "#destroy" do
      setup do
        post :destroy, :user_id => @zooniverse_user.id, :api_key => @zooniverse_user.api_key, :id => @favourite_1.id, :format => :xml
      end
      
      should respond_with :success
      
      should "decrease the number of user favourites by 1" do
        assert_raises(ActiveRecord::RecordNotFound){ @favourite_1.reload }
        assert_equal 1, Favourite.count
      end
    end
    
    context "#destroy on another user's favourite" do
      setup do
        @other_user = Factory :zooniverse_user
        post :destroy, :user_id => @other_user.id, :api_key => @other_user.api_key, :id => @favourite_1.id, :format => :xml
      end
      
      should respond_with :not_found
      
      should "not decrease the number of user favourites by 1" do
        assert_nothing_raised { @favourite_1.reload }
        assert_equal 2, Favourite.count
      end
    end
  end
end
