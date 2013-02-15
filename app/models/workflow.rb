class Workflow < ActiveRecord::Base
  has_many :workflow_tasks
  has_many :classifications
  
  validates_uniqueness_of :name
  
  def self.default
    where(:default => true).first
  end
  
  def tasks
    workflow_tasks
  end
  
  def starting_task
    WorkflowTask.first :conditions => { :workflow_id => id, :parent_id => nil }
  end
end
