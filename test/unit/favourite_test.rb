require 'test_helper'

class FavouriteTest < ActiveSupport::TestCase
  context "A favourite" do
    should belong_to :zooniverse_user
    should belong_to :subject
    
    context "should" do
      setup do
        @favourite = Factory :favourite
      end
    end
    
    context "#create when user doesn't exist" do
      setup do
        @subject = Factory :subject
        @favourite = Favourite.new(:subject_id => @subject.id)
      end
      
      should "fail to create" do
        assert !@favourite.save
      end
    end
    
    context "#create when user does exist" do
      setup do
        @user = Factory :zooniverse_user
        @subject = Factory :subject
        @favourite = Favourite.for_user(@user).build(:subject_id => @subject.id)
      end
      
      should "create successfully" do
        assert @favourite.save
      end
    end
    
    context "#create when subject doesn't exist" do
      setup do
        @user = Factory :zooniverse_user
        @favourite = Favourite.for_user(@user).build(:subject_id => "")
      end
      
      should "fail to create" do
        assert !@favourite.save
      end
    end
    
    context "#create when subject does exist" do
      setup do
        @user = Factory :zooniverse_user
        @subject = Factory :subject
        @favourite = Favourite.for_user(@user).build(:subject_id => @subject.id)
      end
      
      should "create successfully" do
        assert @favourite.save
      end
    end
    
    context "#create when user and subject exist" do
      setup do
        @user = Factory :zooniverse_user
        @subject = Factory :subject
        @favourite = Favourite.for_user(@user).build(:subject_id => @subject.id)
      end
      
      should "create successfully" do
        assert @favourite.save
      end
    end
  end
end
