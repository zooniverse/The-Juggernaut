class CreateWorkflowTasks < ActiveRecord::Migration
  def self.up
    create_table :workflow_tasks, :force => true do |t|
      t.integer :task_id
      t.integer :parent_id
      t.integer :workflow_id
      t.timestamps
    end
    
    add_index :workflow_tasks, :task_id
    add_index :workflow_tasks, :parent_id
    add_index :workflow_tasks, :workflow_id
  end
  
  def self.down
    remove_index :workflow_tasks, :workflow_id
    remove_index :workflow_tasks, :parent_id
    remove_index :workflow_tasks, :task_id
    drop_table :workflow_tasks
  end
end