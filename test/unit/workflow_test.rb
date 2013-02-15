require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  context "A Workflow" do
    should have_many :workflow_tasks
    should have_many :classifications
    
    context "should" do
      setup do
        @workflow = Factory :workflow
      end

      should "return workflow_tasks when calling #tasks" do
        assert_equal @workflow.tasks, @workflow.workflow_tasks
      end
    end
    
    
    context "should" do
      setup do
        @workflow = Factory :workflow
      end
      
      should "have instance methods" do
        assert @workflow.respond_to?(:tasks)
        assert @workflow.respond_to?(:starting_task)
      end
    end
    
    context "should" do
      should "have class methods" do
        assert Workflow.respond_to?(:default)
      end
    end
    
    context "With a defined set of workflow tasks" do
      setup do
        @workflow = Factory :workflow
        @starting_workflow_task = @workflow.workflow_tasks.first
        @child_workflow_task = Factory :workflow_task, :workflow_id => @workflow.id, :parent_id => @starting_workflow_task.id
        @grandchild_workflow_task = Factory :workflow_task, :workflow_id => @workflow.id, :parent_id => @child_workflow_task.id
      end
      
      should "return the correct #starting_task" do
        assert_equal @workflow.starting_task, @starting_workflow_task
      end
    end
  end
end
