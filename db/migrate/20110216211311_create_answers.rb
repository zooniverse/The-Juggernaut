class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers, :force => true do |t|
      t.string :value
      t.text :details
      t.integer :score
      t.integer :task_id
      t.timestamps
    end
    
    add_index :answers, :task_id
  end
  
  def self.down
    remove_index :answers, :task_id
    drop_table :answers
  end
end