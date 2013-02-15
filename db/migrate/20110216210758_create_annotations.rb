class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations, :force => true do |t|
      t.text :value
      t.integer :task_id
      t.integer :answer_id
      t.integer :classification_id
      t.timestamps
    end
    
    add_index :annotations, :classification_id
    add_index :annotations, :task_id
    add_index :annotations, :answer_id
  end
  
  def self.down
    remove_index :annotations, :answer_id
    remove_index :annotations, :task_id
    remove_index :annotations, :classification_id
    drop_table :annotations
  end
end