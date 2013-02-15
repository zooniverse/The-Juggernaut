require 'test_helper'

# Re-raise errors caught by the controller.
class WorkflowsController; def rescue_action(e) raise e end; end

class WorkflowsControllerTest < ActionController::TestCase
  context "A Workflows Controller" do
    setup do
      @controller = WorkflowsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      clear_workflow_session
    end
    
    context "When accessing #classify with an empty session" do
      setup do
        @workflow = Factory :workflow
        @subject = Factory :subject, :workflow_id => @workflow.id
        
        without_cas_login
        get :classify
      end
      
      should respond_with :success
      should render_template :classify
      should set_the_flash.to("You aren't logged in so we can't record your results!")
      
      should "set the workflow session" do
        should_set_workflow_session_with @workflow, nil, @subject
      end
    end
    
    context "When accessing #classify with an empty session and passing a workflow_id" do
      setup do
        @workflow1 = Factory :workflow
        @workflow2 = Factory :workflow, :default => false
        @subject = Factory :subject, :workflow_id => @workflow2.id
        
        without_cas_login
        get :classify, { :id => @workflow2.id }
      end
      
      should respond_with :success
      should render_template :classify
      should set_the_flash.to("You aren't logged in so we can't record your results!")
      
      should "set the workflow session" do
        should_set_workflow_session_with @workflow2, nil, @subject
      end
      
      should 'not display a link to favourite the subject' do
        assert_select '#favourite', false
      end
    end
    
    context 'When accessing #classify while logged in' do
      setup do
        build_workflow
        build_workflow_session_with @workflow, @first_workflow_task
        standard_cas_login
        
        get :classify
      end
      
      should respond_with :success
      should render_template :classify
      
      should 'display a link to favourite the subject' do
        assert_select '#favourite', 1
        assert_select '#favourite a', 1
      end
    end
    
    context "When accessing #classify with a partial results session" do
      setup do
        build_workflow
        build_workflow_session_with @workflow, @first_workflow_task, @subjects
        
        without_cas_login
        get :classify
      end
      
      should respond_with :success
      should render_template :classify
      should set_the_flash.to("You aren't logged in so we can't record your results!")
      
      # i.e. should leave these three session vars the same as we're mid-classification here
      should "set the workflow session" do
        should_set_workflow_session_with @workflow, @first_workflow_task, @subjects
      end
    end
    
    context "When accessing #next_task_or_end and we're not at the end of the decision tree" do
      setup do
        build_workflow
        build_workflow_session_with @workflow, @first_workflow_task, @subjects
        
        @first_workflow_answer_1.next_workflow_task_id = @second_workflow_task.id
        @first_workflow_answer_1.save
        
        get :next_task_or_end, { :id => @first_workflow_answer_1.id, :format => :js }
      end
      
      should respond_with :success
      should render_template :next_task_or_end
      
      should set_session(:current_workflow_id) { @workflow.id }
      should set_session(:current_workflow_task_id) { @second_workflow_task.id }
      should set_session(:current_subject_ids) { [1,2,3] }
      should set_session(:current_subject_locations) { ["http://location/1.jpg", "http://location/2.jpg", "http://location/3.jpg"] }
      
      should "set the workflow session" do
        should_set_workflow_session_with @workflow, @second_workflow_task, @subjects
      end
    end
    
    context "When accessing #next_task_or_end and we ARE at the end of the decision tree (but NOT logged in)" do
      setup do
        build_workflow
        build_workflow_session_with @workflow, @first_workflow_task
        
        get :next_task_or_end, { :id => @first_workflow_answer_1.id, :format => :js }
      end
      
      should respond_with :success
      should render_template :next_task_or_end
      should set_the_flash.to("You aren't logged in so we can't record your results!")
      
      # we should be resetting the session vars here to start the workflow from fresh
      should_not_set_workflow_session
      
      should "not increase the number of classifications" do
        assert_equal 0, Classification.count
      end
    end
    
    context "When accessing #next_task_or_end and we ARE at the end of the decision tree (but ARE logged in)" do
      setup do
        standard_cas_login
        build_workflow
        
        @first_workflow_task.task = Factory(:task, :has_defined_answer => true)
        @first_workflow_task.save
        
        @first_workflow_answer_1.answer = Factory(:answer, :task => @first_workflow_task.task)
        @first_workflow_answer_1.save
        
        build_workflow_session_with @workflow, nil
        @request.session['current_workflow_task_id'] = nil
        
        @old_classification_count = Classification.count
        
        get :next_task_or_end, { :id => @first_workflow_answer_1.id, :format => :js }
      end
      
      should respond_with :success
      should render_template :next_task_or_end
      should_not set_the_flash
      
      # we should be resetting the session vars here to start the workflow from fresh
      should_not_set_workflow_session
      
      should "increase the number of classifications" do
        assert_equal @old_classification_count + 1, Classification.count
      end
    end
    
    context "When mid-classification and hitting rewind link (with a valid session)" do
      setup do
        build_workflow
        build_workflow_session_with @workflow, @third_workflow_task, @subjects
        
        @request.session['result'] = [{
                                        :subjects => @subjects.collect(&:id),
                                        :workflow_answer_id => @first_workflow_answer_1.id,
                                        :answer_id => @first_workflow_answer_1.answer.id,
                                        :workflow_task_id => @first_workflow_task.id,
                                        :task_id => @first_workflow_task.task.id},
                                      { :subjects => @subjects.collect(&:id),
                                        :workflow_answer_id => @second_workflow_answer_2.id,
                                        :answer_id => @first_workflow_answer_2.answer.id,
                                        :workflow_task_id => @second_workflow_task.id,
                                        :task_id => @second_workflow_task.task.id
                                     }]
        
        get :rewind, { :id => @second_workflow_task.id, :format => :js }
      end
      
      should "set the workflow session" do
        should_set_workflow_session_with @workflow, @second_workflow_task, @subjects
      end
      
      should set_session(:result) do
        [{
          :subjects => @subjects.collect(&:id),
          :workflow_answer_id => @first_workflow_answer_1.id,
          :answer_id => @first_workflow_answer_1.answer.id,
          :workflow_task_id => @first_workflow_task.id,
          :task_id => @first_workflow_task.task.id
        }]
      end
    end
    
    context "When mid-classification and hitting rewind link (with an INVALID session)" do
      setup do
        build_workflow
        build_workflow_session_with @workflow, @third_workflow_task
        @request.session['result'] = []
        
        get :rewind, { :id => @second_workflow_task.id, :format => :js }
      end
      
      # failing gracefully by deleting the session vars and starting again
      should_not_set_workflow_session
      should set_the_flash.to("There was a problem recording your classification")
      should redirect_to('/classify'){ classify_path }
    end
    
    context 'When favouriting an asset' do
      setup do
        @user = Factory :zooniverse_user
        standard_cas_login(@user)
        build_workflow
        build_workflow_session_with @workflow, @first_workflow_task, @subjects
        
        get :add_favourites, { :format => :js }
      end
      
      should respond_with :success
      
      should 'create a favourite' do
        assert_same_elements @user.favourites.collect(&:subject), @subjects
      end
    end
  end
end
