require 'test_helper'

class Public::SubjectsController; def rescue_action(e) raise e end; end

class Public::SubjectsControllerTest < ActionController::TestCase
  context "Public Subjects Controller" do
    setup do
      @controller = Public::SubjectsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    context "When showing an Subject and passing a valid api_key" do
      setup do
        @zooniverse_user = Factory :zooniverse_user, :api_key => "1234"
        @subject = Factory :subject
        get :show, {:id => @subject.id, :api_key => @zooniverse_user.api_key, :format => :xml}
      end
      
      should respond_with 200
      should respond_with_content_type(:xml)
    end
    
    context "When showing an Subject and passing no api_key" do
      setup do
        @zooniverse_user = Factory :zooniverse_user, :api_key => "1234"
        @subject = Factory :subject
        get :show, {:id => @subject.id, :format => :xml}
      end
      
      should respond_with 403
      should respond_with_content_type(:xml)
    end
  end
end
