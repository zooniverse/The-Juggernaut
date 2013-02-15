class WorkflowAnswer < ActiveRecord::Base
  belongs_to :answer
  belongs_to :workflow_task
  
  def ends_workflow?
    next_workflow_task_id.nil?
  end
  
  def next_workflow_task
    WorkflowTask.find(next_workflow_task_id)
  end
  
  def value
    answer.value
  end
end
