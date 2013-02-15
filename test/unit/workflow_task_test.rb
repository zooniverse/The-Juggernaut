require 'test_helper'

class WorkflowTaskTest < ActiveSupport::TestCase
  context "A WorkflowTask" do
    should belong_to :workflow
    should belong_to :task
    
    context "should alias" do
      setup do
        @workflow_task = Factory :workflow_task
      end

      should "#answers with #workflow_answers" do
        assert_equal @workflow_task.answers, @workflow_task.workflow_answers
      end
    end
    
    context "should alias" do
      setup do
        @workflow_task = Factory :workflow_task
      end

      should "#name to task name" do
        assert_equal @workflow_task.name, @workflow_task.task.name
      end
    end
    
    context "should" do
      setup do
        @workflow_task = Factory :workflow_task
      end

      should "have instance methods" do
        assert @workflow_task.respond_to?(:answers)
        assert @workflow_task.respond_to?(:first_task?)
        assert @workflow_task.respond_to?(:name)        
        assert @workflow_task.respond_to?(:has_ancestors?)        
      end
    end
    
    context "With no children" do
      setup do
        @workflow_task = Factory :workflow_task
      end
    
      should "have no children!" do
        assert @workflow_task.children.empty?
      end
    end
    
    context "With children" do
      setup do
        @workflow_task = Factory :workflow_task
        @child_workflow_task_1 = Factory :workflow_task, :parent_id => @workflow_task.id
        @child_workflow_task_2 = Factory :workflow_task, :parent_id => @workflow_task.id
      end

      should "return array of children" do
        assert_equal @workflow_task.children.size, 2
        assert_equal @workflow_task.children, [@child_workflow_task_1, @child_workflow_task_2]
      end
    end
    
    context "With no parent" do
      setup do
        @workflow_task = Factory :workflow_task
      end

      should "be the start of the workflow" do
        assert @workflow_task.first_task?
        assert !@workflow_task.has_ancestors?
      end
    end
    
    context "With parents" do
      setup do
        @parent_workflow_task = Factory :workflow_task
        @workflow_task = Factory :workflow_task, :parent_id => @parent_workflow_task.id
      end

      should "not be the start of the workflow" do
        assert !@workflow_task.first_task?
        assert @workflow_task.has_ancestors?
      end
    end
  end
end
