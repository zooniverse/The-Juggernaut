class Annotation < ActiveRecord::Base
  belongs_to :task
  belongs_to :answer
  belongs_to :classification
  
  before_save :check_valid_task_answer, :if => :task_has_defined_answer?
  
  def check_valid_task_answer
    Answer.where(:task_id => task_id).exists?(:id => answer_id)
  end
  
  def task_has_defined_answer?
    task.has_defined_answer?
  end
end