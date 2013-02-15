require 'test_helper'

# Re-raise errors caught by the controller.
class Api::TasksController; def rescue_action(e) raise e end; end

class Api::TasksControllerTest < ActionController::TestCase
  context "Tasks Controller" do
    setup do
      @controller = Api::TasksController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      
      @task = Factory :task
      @answer = Factory :answer, :task => @task
      @task2 = Factory :task
    end
    
    context "#index not logged in" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :index, { :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#index when logged in" do
      setup do
        api_login
        get :index, { :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "render XML correctly" do
        assert_select "tasks", 1
        assert_select "task", 2
        
        [@task, @task2].each do |task|
          assert_select "id",  "#{ task.id }"
          assert_select "name", "#{ task.name }"
          assert_select "subject_count", "#{ task.count }"
        end
      end
    end
    
    context "#show when not logged in" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :show, { :id => @task.id, :format => :xml }
      end
      
      should respond_with :unauthorized
    end
    
    context "#show when logged in" do
      setup do
        api_login
        get :show, { :id => @task.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type :xml
      
      should "render XML correctly" do
        assert_select "task", 1
        assert_select "id",  "#{ @task.id }"
        assert_select "name", "#{ @task.name }"
        assert_select "responses", 1
        assert_select "response", "#{ @answer.value }"
      end
    end
  end
end
