require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context "A task" do
    setup do
      @task = Factory :task
    end
    
    should have_many :annotations
    should have_many :answers
    should validate_presence_of :name
    
    should "validate uniqueness of :name" do
      validate_uniqueness_of(:name).with_message(/must be unique/)
    end
  end
end
