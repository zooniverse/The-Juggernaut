class CreateWorkflows < ActiveRecord::Migration
  def self.up
    create_table :workflows, :force => true do |t|
      t.string :name
      t.text :details
      t.boolean :default
      t.timestamps
    end
    
    add_index :workflows, :default
  end
  
  def self.down
    remove_index :workflows, :default
    drop_table :workflows
  end
end