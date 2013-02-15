require 'test_helper'

class ZooniverseUserTest < ActiveSupport::TestCase
  context "A ZooniverseUser" do
    should have_many :classifications
    should have_many :favourites
    should have_many :groups
    
    context "with classifications" do
      setup do
        @zooniverse_user = Factory :zooniverse_user
        3.times{ |i| Factory(:classification, :zooniverse_user => @zooniverse_user, :created_at => i.minutes.ago) }
        @last_one = Classification.last
      end
      
      should "find the last classification" do
        assert_equal @last_one, @zooniverse_user.send(:last_classification)
        assert_equal @last_one.created_at, @zooniverse_user.last_active_at
        assert_equal @last_one.subject, @zooniverse_user.last_classified
      end
    end
    
    context "without classifications" do
      setup do
        @zooniverse_user = Factory :zooniverse_user
      end
      
      should "find the last classification" do
        assert @zooniverse_user.send(:last_classification).new_record?
        assert_equal nil, @zooniverse_user.last_active_at
        assert_equal nil, @zooniverse_user.last_classified
      end
    end
    
    context "When set to admin" do
      setup do
        @zooniverse_user = Factory :zooniverse_user, :admin => true
      end

      should "be #admin?" do
        assert @zooniverse_user.admin?
      end
    end
    
    context "A standard user" do
      setup do
        @zooniverse_user = Factory :zooniverse_user
      end

      should "not be #admin?" do
        assert !@zooniverse_user.admin?
      end
    end
    
    context "updating activity count" do
      setup do
        @zooniverse_user = Factory :zooniverse_user
        @workflow = Factory :workflow
        
        2.times{ @zooniverse_user.update_activity_count(@workflow.id) }
        @activity = Activity.first
      end
      
      should "increment correctly" do
        assert_equal 1, Activity.count
        assert_equal 2, @activity.counter
        assert_equal @zooniverse_user, @activity.user
        assert_equal @workflow, @activity.workflow
      end
      
      context "by decrementing existing activity count" do
        setup do
          @zooniverse_user.update_activity_count(@workflow.id, false)
        end
        
        should "decrement correctly" do
          assert_equal 1, Activity.count
          assert_equal 1, @activity.reload.counter
          assert_equal @zooniverse_user, @activity.user
          assert_equal @workflow, @activity.workflow
        end
      end
      
      context "by decrementing new activity count" do
        setup do
          @workflow2 = Factory :workflow
          @zooniverse_user.update_activity_count(@workflow2.id, false)
        end
        
        should "not decrement anything" do
          assert_equal 1, Activity.count
          assert_equal 2, @activity.reload.counter
          assert_equal [@activity], @zooniverse_user.reload.activities
        end
      end
    end
  end
end
