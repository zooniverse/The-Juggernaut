require 'test_helper'

class WorkflowAnswerTest < ActiveSupport::TestCase
  context "A Workflow Answer" do
    should belong_to :workflow_task
    should belong_to :answer
    
    context "should" do
      setup do
        @workflow_answer = Factory :workflow_answer
      end

      should "have instance methods" do
        assert @workflow_answer.respond_to?(:ends_workflow?)
        assert @workflow_answer.respond_to?(:next_workflow_task)
        assert @workflow_answer.respond_to?(:value)        
      end
    end
    
    context "With a blank next_workflow_task_id" do
      setup do
        @workflow_answer = Factory :workflow_answer, :next_workflow_task_id => nil
      end

      should "#ends_workflow?" do
        assert @workflow_answer.ends_workflow?
      end
    end
    
    context "With a following workflow task" do
      setup do
        @next_workflow_task = Factory :workflow_task
        @workflow_answer = Factory :workflow_answer, :next_workflow_task_id => @next_workflow_task.id
      end

      should "not #ends_workflow?" do
        assert !@workflow_answer.ends_workflow?
      end
      
      should "return #next_workflow_task" do
        assert_equal @workflow_answer.next_workflow_task, @next_workflow_task
      end
    end
    
    context "When asked for its value" do
      setup do
        @answer = Factory :answer
        @workflow_answer = Factory :workflow_answer, :answer_id => @answer.id
      end

      should "return associated answer value" do
        assert_equal @answer.value, @workflow_answer.value
      end
    end
  end
end
