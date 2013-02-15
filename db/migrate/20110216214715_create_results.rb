class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results, :force => true do |t|
      t.text :value
      t.timestamps
    end
  end
  
  def self.down
    drop_table :results
  end
end
