require 'test_helper'

class Api::ClassificationsController; def rescue_action(e) raise e end; end

class Api::ClassificationsControllerTest < ActionController::TestCase
  context "Classifications Controller" do
    setup do
      @controller = Api::ClassificationsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
      
    context "#index not logged in" do
      setup do
        @request.env['HTTPS'] = 'on'
        get :index, { :format => :xml }
      end
      
      should respond_with 401
    end
    
    context "#index logged in" do
      setup do
        api_login
        get :index, { :format => :xml }
      end
    
      should respond_with 403
    end
      
    context "#index not logged in passing a zooniverse_user_id" do
      setup do
        @request.env['HTTPS'] = 'on'
        @zooniverse_user = Factory :zooniverse_user
        get :index, { :user_id => @zooniverse_user.id, :format => :xml }
      end
      
      should respond_with 401
    end
    
    context "#index logged in passing a zooniverse_user_id" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @classification = Factory :classification, :zooniverse_user => @zooniverse_user
        get :index, { :user_id => @zooniverse_user.id, :format => :xml }
      end
      
      should respond_with 200
      should respond_with_content_type(:xml)
      
      should "have correctly formed XML" do
        assert_select "zooniverse_user_id", "#{ @zooniverse_user.id }"
        assert_select "classifications", 1
        assert_select "classification", 1
        assert_select "annotations", 1
        assert_select "annotation", 1
        assert_select "subjects", 1
        assert_select "subject", 1
      end
    end
    
    context "#index logged in passing a zooniverse_user_id and date range" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @classification = Factory :classification, :zooniverse_user => @zooniverse_user
        get :index, { :user_id => @zooniverse_user.id, :from => 1.hour.ago, :to => 1.hour.from_now, :format => :xml }
      end
      
      should respond_with 200
      should respond_with_content_type(:xml)
      
      should "have correctly formed XML" do
        assert_select "zooniverse_user_id", "#{ @zooniverse_user.id }"
        assert_select "classifications", 1
        assert_select "classification", 1
        assert_select "annotations", 1
        assert_select "annotation", 1
        assert_select "subjects", 1
        assert_select "subject", 1
      end
    end
    
    context "#index logged in passing invalid zooniverse_user_id and date range" do
      setup do
        api_login
        @classification = Factory :classification
        get :index, { :user_id => 1234, :from => Time.now-1.hour, :to => Time.now, :format => :xml }
      end
      
      should respond_with :forbidden
    end
    
    context "#index logged in passing a zooniverse_user_id and a page_id" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        30.times do
          @classification = Factory :classification, :zooniverse_user => @zooniverse_user
        end
        get :index, { :user_id => @zooniverse_user.id, :page => 2, :format => :xml }
      end
      
      should respond_with 200
      should respond_with_content_type(:xml)
      
      should "have correctly formed XML" do
        assert_select "zooniverse_user_id", "#{ @zooniverse_user.id }"
        assert_select "classifications", 1
        assert_select "classification", 10
        assert_select "annotations", 10
        assert_select "annotation", 10
        assert_select "subjects", 10
        assert_select "subject", 10
      end
    end
    
    context "#index logged in passing a zooniverse_user_id and a page_id" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @classification = Factory :classification, :zooniverse_user => @zooniverse_user
        get :index, { :user_id => 123456, :page => 2, :format => :xml }
      end
      
      should respond_with :forbidden
    end
    
    context "#show not logged in" do
      setup do 
        @request.env['HTTPS'] = 'on'    
        @classification = Factory :classification
        get :show, { :id => @classification.id, :format => :xml }
      end
      
      should respond_with 401
    end
    
    context "#show when logged in" do
      setup do 
        api_login
        @classification = Factory :classification
        get :show, { :id => @classification.id, :format => :xml }
      end
      
      should respond_with 200
      should respond_with_content_type(:xml)
      
      should "have proper XML for classification" do
        assert_select "classification", 1
        assert_select "id", "#{ @classification.id }"
        assert_select "subjects", 1
        assert_select "subject", 1
        assert_select "annotations", 1
        assert_select "annotation", 1
      end
    end
    
    context "#create logged in" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @task = Factory :task
        @subject = Factory :subject
        @workflow = Factory :workflow
        @old_count = @subject.classification_count
        options = {:classification => { :started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow.id, :subjects => [{:id => @subject.id}], :zooniverse_user_id => @zooniverse_user.id, :annotations => [:task_id => @task.id, :value => "Spiral"]}, :format => :xml}
        post :create, options
      end
    
      should respond_with 201
    
      should "increase the Subject classification_count by 1" do
        subject = Subject.find(@subject.id)
        assert_equal subject.classification_count, @old_count + 1
      end
    end
    
    context "#create logged in passing a bad annotation value (when there are defined answers)" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @task = Factory :task, :has_defined_answer => true
        @subject = Factory :subject
        @workflow = Factory :workflow

        @old_user_activity_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter
        @old_subject_classification_count = @subject.classification_count
        @old_classification_count = Classification.count
        @old_annotation_count = Annotation.count
        @old_subject_classification_count = SubjectClassification.count
        options = {:classification => { :started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow.id, :subjects => [{:id => @subject.id}], :zooniverse_user_id => @zooniverse_user.id, :annotations => [:task_id => @task.id, :value => "Boxy"]}, :format => :xml }
        post :create, options
      end
    
      should respond_with 422 #unprocessible entity
    
      should "not increase the Classification count" do
        assert_equal Classification.count, @old_classification_count
      end
      
      should "not increase the Annotation count" do
        assert_equal Annotation.count, @old_annotation_count
      end
      
      should "not increase the SubjectClassification count" do
        assert_equal SubjectClassification.count, @old_subject_classification_count
      end
      
      should "not increase the Subject classification count" do
        subject = Subject.find(@subject.id)
        assert_equal subject.classification_count, @old_subject_classification_count
      end
      
      should "not increase the User activity count for workflow" do
        @new_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        assert_equal @new_count, @old_user_activity_count
      end
    end
    
    context "#create logged in passing a bad subject value" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @task = Factory :task
        @workflow = Factory :workflow
        @old_user_activity_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        @old_classification_count = Classification.count
        @old_annotation_count = Annotation.count
        @old_subject_classification_count = SubjectClassification.count
        options = {:classification => { :started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow.id, :subjects => [{:id => 100}], :zooniverse_user_id => @zooniverse_user.id, :annotations => [:task_id => @task.id, :value => "Spiral"]}, :format => :xml}
        post :create, options
      end
    
      should respond_with 422 #unprocessible entity
    
      should "not increase the Classification count" do
        assert_equal Classification.count, @old_classification_count
      end
      
      should "not increase the Annotation count" do
        assert_equal Annotation.count, @old_annotation_count
      end
      
      should "not increase the SubjectClassification count" do
        assert_equal SubjectClassification.count, @old_subject_classification_count
      end
      
      should "not increase the User classification count" do
        @new_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        assert_equal @new_count, @old_user_activity_count
      end
    end
    
    context "#create logged in passing a free-form value (when there are no defined answers)" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @task = Factory :task, :has_defined_answer => false
        @subject = Factory :subject
        @workflow = Factory :workflow
        @old_user_activity_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        @old_subject_classification_count = @subject.classification_count
        @old_classification_count = Classification.count
        @old_annotation_count = Annotation.count
        @old_subject_classification_count = SubjectClassification.count
        options = {:classification => { :started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow.id, :subjects => [{:id => @subject.id}], :zooniverse_user_id => @zooniverse_user.id, :annotations => [:task_id => @task.id, :value => "Free-form answer value"]}, :format => :xml}
        post :create, options
      end
    
      should respond_with 201
    
      should "increase the Classification count by 1" do
        assert_equal Classification.count, @old_classification_count + 1
      end
      
      should "increase the Annotation count by 1" do
        assert_equal Annotation.count, @old_annotation_count + 1
      end
      
      should "increase the SubjectClassification count by 1" do
        assert_equal SubjectClassification.count, @old_subject_classification_count + 1
      end
      
      should "increase the Subject classification count by 1" do
        subject = Subject.find(@subject.id)
        assert_equal subject.classification_count, @old_subject_classification_count + 1
      end
      
      should "increase the User classification count by 1" do
        @new_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        assert_equal @new_count, @old_user_activity_count + 1
      end
    end
    
    context "#create when passing no annotations" do
      setup do
        api_login
        @zooniverse_user = Factory :zooniverse_user
        @task = Factory :task, :has_defined_answer => false
        @subject = Factory :subject
        @workflow = Factory :workflow
        @old_user_activity_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        @old_subject_classification_count = @subject.classification_count
        @old_classification_count = Classification.count
        @old_annotation_count = Annotation.count
        @old_subject_classification_count = SubjectClassification.count
        options = {:classification => { :started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow_id, :subjects => [{:id => @subject.id}], :zooniverse_user_id => @zooniverse_user.id, :annotations => []}, :format => :xml}
        post :create, options
      end
    
      should respond_with 422 #unprocessible entity
      
      should "not increase the Classification count" do
        assert_equal Classification.count, @old_classification_count
      end
      
      should "not increase the Annotation count" do
        assert_equal Annotation.count, @old_annotation_count
      end
      
      should "not increase the SubjectClassification count" do
        assert_equal SubjectClassification.count, @old_subject_classification_count
      end
      
      should "not increase the User classification count" do
        @new_count = @zooniverse_user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter        
        assert_equal @new_count, @old_user_activity_count
      end
    end
  end
end