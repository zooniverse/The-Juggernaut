class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks, :force => true do |t|
      t.string :name
      t.integer :count
      t.boolean :has_defined_answer
      t.timestamps
    end
  end
  
  def self.down
    drop_table :tasks
  end
end
