require 'test_helper'

class SubjectTest < ActiveSupport::TestCase
  context "A subject" do
    should have_many :subject_classifications
    should have_many(:classifications).through(:subject_classifications)
    
    should have_many :result_subjects
    should have_many(:results).through(:result_subjects)
    should have_many :favourites
    should have_many :groups
    
    should validate_presence_of :name
    
    context "When passed an invalid file type" do
      setup do
        @file = File.new("#{ Rails.root }/test/fixtures/test_word_doc.doc")
      end
      
      should "not be #supported_content_type?" do
        assert !Subject.supported_content_type?(@file)
      end
    end
    
    context "When passed a valid file type" do
      setup do
        @file = File.new("#{ Rails.root }/test/fixtures/test_file.txt")
        Subject.unstub :supported_content_type?
      end
      
      should "be #supported_content_type?" do
        assert Subject.supported_content_type?(@file)
      end
    end
    
    context "With a mix of of different ages" do
      setup do
        3.times do
          subject = Factory :subject
          subject.created_at = 3.weeks.ago
          subject.save
        end
        
        2.times do
          Factory :subject
        end
      end
      
      should "named_scope #recents should return correct numbers" do
        assert_equal Subject.recent(1.day.ago).size, 2
        assert_equal Subject.recent(4.weeks.ago).size, 5
      end
    end
    
    context "When there is only one subject that a user hasn't classified" do
      setup do
        @subject1 = Factory :subject
        @subject2 = Factory :subject
        @subject3 = Factory :subject
        @user = Factory :zooniverse_user
        @classification1 = Factory :classification, :zooniverse_user => @user, :subjects => [@subject1]
        @classification2 = Factory :classification, :zooniverse_user => @user, :subjects => [@subject2]
      end
      
      should "return correct subject for #next_original_for_user" do
        assert_equal Subject.next_original_for_user(@user), @subject3
      end
    end
    
    context "When there user hasn't classified" do
      setup do
        3.times{ Factory :subject }
        @user = Factory :zooniverse_user
      end
      
      should "return correct subject for #next_original_for_user" do
        assert_contains Subject.all, Subject.next_original_for_user(@user)
      end
    end
    
    context "With a mix of active and inactive subjects" do
      setup do
        @subject1 = Factory :subject, :active => true
        @subject2 = Factory :subject, :active => false
        @subject3 = Factory :subject, :active => true
      end
      
      should "return correct number of active subjects for named_scope" do
        assert_equal Subject.active.size, 2
        assert_equal Subject.count, 3
      end
    end
    
    context "updating classification count" do
      setup do
        @subject = Factory :subject
      end
      
      should "#update_classification_count" do
        1.upto(2) do |i|
          @subject.update_classification_count
          assert_equal i, @subject.reload.classification_count
        end
      end
    end
    
    context "using the cache" do
      setup do
        5.times{ Factory :subject, :workflow_id => 1 }
        @workflow_subjects = Subject.all
        5.times{ Factory :subject, :workflow_id => 2 }
        @other_subjects = Subject.where(:workflow_id => 2).all
      end
      
      should "find #cached_subjects" do
        assert_same_elements Subject.all, Subject.cached_subjects
        assert_same_elements Subject.all, Subject.cached_subjects
      end
      
      should "find #cached_count" do
        assert_equal 10, Subject.cached_count
        assert_equal 10, Subject.cached_count
      end
      
      should "find #cached_subjects_for_workflow" do
        assert_same_elements @workflow_subjects, Subject.cached_subjects_for_workflow(1)
        assert_same_elements @workflow_subjects, Subject.cached_subjects_for_workflow(1)
      end
      
      should "find #cached_count_for_workflow" do
        assert_equal 5, Subject.cached_count_for_workflow(1)
        assert_equal 5, Subject.cached_count_for_workflow(1)
      end
      
      should "find #next_for_classification" do
        assert_contains Subject.all, Subject.next_for_classification.first
      end
      
      should "find #next_for_workflow" do
        assert_contains @workflow_subjects, Subject.next_for_workflow(1).first
        assert_contains @other_subjects, Subject.next_for_workflow(2).first
      end
    end
    
    context "#create_and_upload with an invalid content type" do
      setup do
        S3Uploader.stubs(:upload_subject).returns(true)
        Subject.stubs(:supported_content_type?).returns(false)
        incoming = { :subject => { :name => "an subject" }, :file => { } }
        @subject = Subject.create_and_upload incoming
      end
      
      should "contain #upload_errors" do
        assert_equal ["Invalid content type"], @subject.upload_errors
        assert @subject.destroyed?
      end
    end
    
    context "#create_and_upload when the upload fails" do
      setup do
        S3Uploader.stubs(:upload_subject).returns(false)
        Subject.stubs(:supported_content_type?).returns(true)
        incoming = { :subject => { :name => "an subject" }, :file => { } }
        @subject = Subject.create_and_upload incoming
      end
      
      should "contain #upload_errors" do
        assert_equal ["Upload failed"], @subject.upload_errors
        assert @subject.destroyed?
      end
    end
    
    context "#create_and_upload when everything goes well" do
      setup do
        S3Uploader.stubs(:upload_subject).returns(true)
        Subject.stubs(:supported_content_type?).returns(true)
        incoming = { :subject => { :name => "an subject" }, :file => { } }
        @subject = Subject.create_and_upload incoming
      end
      
      should "create_and_upload successfully" do
        assert_empty @subject.upload_errors
        assert_nothing_raised { @subject.reload }
        assert Subject.exists?(@subject.id)
      end
    end
  end
end
