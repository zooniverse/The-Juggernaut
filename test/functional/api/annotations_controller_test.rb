require 'test_helper'

# Re-raise errors caught by the controller.
class Api::AnnotationsController; def rescue_action(e) raise e end; end

class Api::AnnotationsControllerTest < ActionController::TestCase
  context "Annotations controller" do
    setup do
      @controller = Api::AnnotationsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @request.env['HTTPS'] = 'on'
    end
    
    context "#index not logged in" do
      setup do
        get :index, { :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#index logged in" do
      setup do
        api_login
        get :index, { :format => :xml }
      end
      
      should respond_with :forbidden
    end
    
    context "#index not logged in and passing a task_id" do
      setup do
        @task = Factory :task
        @user = Factory :zooniverse_user
        @annotation1 = Factory :annotation, :task => @task
        @annotation2 = Factory :annotation, :task => @task
        get :index, { :task_id => @task.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#index logged in passing a task_id" do
      setup do
        api_login
        @task = Factory :task
        @classification = Factory :classification
        @annotation = Factory :annotation, :classification => @classification, :task => @task
        get :index, { :task_id => @task.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type(:xml)
    end
    
    context "#index logged in passing a task_id and date range" do
      setup do
        api_login
        @task = Factory :task
        @classification = Factory :classification
        @annotation = Factory :annotation, :classification => @classification, :task => @task
        get :index, { :task_id => @task.id, :from => Time.now-1.day, :to => Time.now, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type(:xml)
    end
    
    context "#index logged in passing an invalid task_id and date range" do
      setup do
        api_login
        @classification = Factory :classification
        @annotation = Factory :annotation, :classification => @classification
        get :index, { :task_id => 123, :from => Time.now-1.day, :to => Time.now, :format => :xml }
      end
      
      should respond_with :forbidden
    end
    
    context "#show not logged in" do
      setup do
        @annotation = Factory :annotation
        get :show, { :id => @annotation.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#show logged in as an api user" do
      setup do
        api_login
        @classifying_user = Factory :zooniverse_user
        @classification = Factory :classification, :zooniverse_user => @classifying_user
        @annotation = Factory :annotation, :classification => @classification
        get :show, { :id => @annotation.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type(:xml)
    end
  end
end
