class WorkflowTask < ActiveRecord::Base
  belongs_to :task
  belongs_to :workflow
  has_many :workflow_answers, :dependent => :destroy
  acts_as_tree :order => 'id'
    
  def answers
    workflow_answers
  end
  
  def first_task?
    parent.nil?
  end
  
  def name
    task.name
  end
  
  def has_ancestors?
    ancestors.empty? ? false : true
  end
end
