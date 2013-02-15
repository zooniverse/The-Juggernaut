require 'test_helper'

class ClassificationTest < ActiveSupport::TestCase

  context "A classification" do
    should have_many :subject_classifications
    should have_many(:subjects).through(:subject_classifications)
    should have_many :annotations
    should belong_to :zooniverse_user
    should belong_to :workflow
    # should_validate_presence_of :started, :ended, :zooniverse_user_id, :workflow_id, :locale
  end
  
  context "should" do
    setup do
      @classification = Factory :classification
    end

    should "have instance methods" do
      assert @classification.respond_to?(:increment_user_activity_count)
      assert @classification.respond_to?(:decrement_user_activity_count)
      assert @classification.respond_to?(:subject)
      assert @classification.respond_to?(:calculate_score)
    end
  end
  
  context "should" do
    should "have class methods" do
      assert Classification.respond_to?(:create_with_subjects_and_annotations)
      assert Classification.respond_to?(:scoring?)
      assert Classification.respond_to?(:in_period)
    end
  end
  
  context "When counting classifications in date range" do
    setup do
      5.times do
        Factory :classification, :created_at => 10.days.ago
      end
      4.times do
        Factory :classification, :created_at => 5.days.ago
      end
    end

    should "return correct count" do
      assert_equal 4, Classification.in_period(9.days.ago, 3.days.ago)
    end
  end
  
  
  context "When a classification is created the User activity count for that workflow" do
    setup do
      @user = Factory :zooniverse_user
      @workflow = Factory :workflow
      @old_count = @user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter
      @classification = Factory :classification, :zooniverse_user => @user, :workflow => @workflow
    end

    should "increase by 1" do
      @new_count = @user.activities.find_by_workflow_id(@classification.workflow.id).counter
      assert_equal @old_count+1, @new_count
    end
  end
  
  context "When a classification is destroyed the User activity for that workflow" do
    setup do
      @user = Factory :zooniverse_user
      @workflow = Factory :workflow
      @classification = Factory :classification, :zooniverse_user => @user, :workflow => @workflow
      @old_count = @user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter
      @classification.destroy
    end
  
    should "decrease by 1" do
      @new_count = @user.activities.find_or_initialize_by_workflow_id(@workflow.id).counter
      assert_equal @new_count, @old_count-1
    end
  end
  
  context "When passed subjects with annotations that are valid" do
    setup do
      @user = Factory :zooniverse_user
      @subject = Factory :subject
      @workflow = Factory :workflow
      @task = Factory :task, :has_defined_answer => true
      @answer = Factory :answer, :task_id => @task.id, :score => 2
      @classification_count = Classification.count
      Classification.stubs(:scoring?).returns(true)
      subjects_and_annotations = {:started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow.id, :zooniverse_user_id => @user.id, :subjects => [{:id => @subject.id}], :annotations => [{:task_id => @task.id, :answer_id => @answer.id}]}
      Classification.create_with_subjects_and_annotations(subjects_and_annotations)
    end
  
    should "create a new classification" do
      new_count = @classification_count + 1
      assert_equal new_count, Classification.count
      assert_equal Classification.last.total_score, 2
    end
  end
  
  context "When passed subjects with annotations that are valid the subject average_score" do
    setup do
      @user = Factory :zooniverse_user
      @subject = Factory :subject
      @workflow = Factory :workflow
      @old_classification = Factory :classification, :subjects => [@subject], :total_score => 1, :zooniverse_user => @user
      @task = Factory :task, :has_defined_answer => true
      @answer = Factory :answer, :task_id => @task.id, :score => 2
      @classification_count = Classification.count
      Classification.stubs(:scoring?).returns(true)
      subjects_and_annotations = {:started => Time.now, :ended => Time.now, :locale => 'en', :workflow_id => @workflow.id, :zooniverse_user_id => @user.id, :subjects => [{:id => @subject.id}], :annotations => [{:task_id => @task.id, :answer_id => @answer.id}]}
      Classification.create_with_subjects_and_annotations(subjects_and_annotations)
    end
  
    should "be calculated correctly" do
      subject = Subject.find(@subject.id)
      assert_equal subject.average_score, 1.5
    end
  end
  
  context "When passed subjects with annotations that are invalid because of defined task answer" do
    setup do
      @user = Factory :zooniverse_user
      @subject = Factory :subject
      @task = Factory :task, :has_defined_answer => true
      @answer = Factory :answer, :task_id => @task.id
      @classification_count = Classification.count
      subjects_and_annotations = {:started => Time.now, :ended => Time.now, :locale => 'en', :zooniverse_user_id => @user.id, :subjects => [{:id => @subject.id}], :annotations => [{:task_id => @task.id, :answer_id => 100}]}
      Classification.create_with_subjects_and_annotations(subjects_and_annotations)
    end
  
    should "NOT create a new classification (because :answer_id is invalid)" do
      assert_equal @classification_count, Classification.count
    end
  end
  
  context "When passed subjects and no annotations!" do
    setup do
      @user = Factory :zooniverse_user
      @subject = Factory :subject
      @task = Factory :task, :has_defined_answer => true
      @answer = Factory :answer, :task_id => @task.id
      @classification_count = Classification.count
      subjects_and_annotations = {:started => Time.now, :ended => Time.now, :locale => 'en', :zooniverse_user_id => @user.id, :subjects => [{:id => @subject.id}], :annotations => [{}]}
      Classification.create_with_subjects_and_annotations(subjects_and_annotations)
    end
  
    should "NOT create a new classification (because there were no annotations)" do
      assert_equal @classification_count, Classification.count
    end
  end
end
