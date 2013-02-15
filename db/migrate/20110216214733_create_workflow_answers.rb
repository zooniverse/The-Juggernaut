class CreateWorkflowAnswers < ActiveRecord::Migration
  def self.up
    create_table :workflow_answers, :force => true do |t|
      t.integer :answer_id
      t.integer :workflow_task_id
      t.integer :next_workflow_task_id
      t.timestamps
    end
    
    add_index :workflow_answers, :answer_id
    add_index :workflow_answers, :workflow_task_id
  end
  
  def self.down
    remove_index :workflow_answers, :workflow_task_id
    remove_index :workflow_answers, :answer_id
    drop_table :workflow_answers
  end
end