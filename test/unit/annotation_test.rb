require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase
  
  context "An annotation" do
    should belong_to :task
    should belong_to :answer
    should belong_to :classification
  end
  
  context "An annotation" do
    setup do
      @annotation = Factory :annotation
    end

    should "respond_to?" do
      assert @annotation.respond_to?(:check_valid_task_answer)
    end
  end
  
  context "When an annotation is created with an unacceptable value (and there are defined answers)" do
    setup do
      @task = Factory :task, :has_defined_answer => true
      @user = Factory :zooniverse_user
      @annotation = Annotation.new(:task_id => @task.id, :value => "Not acceptable")
    end
  
    should "fail to create" do
      assert !@annotation.save
    end
  end
  
  context "When an annotation is created with a free-form value (and there are no defined answers)" do
    setup do
      @task = Factory :task, :has_defined_answer => false
      @user = Factory :zooniverse_user
      @annotation = Annotation.new(:task_id => @task.id, :value => "Free-form value")
    end
  
    should "create" do
      assert @annotation.save
    end
  end
  
  context "When an annotation is created with an acceptable value" do
    setup do
      @task = Factory :task, :has_defined_answer => true
      @user = Factory :zooniverse_user
      @answer = Factory :answer, :task_id => @task.id
      @annotation = Annotation.new(:task_id => @task.id, :answer_id => @answer.id)
    end

    should "be created" do
      assert @annotation.save
    end
  end
end
