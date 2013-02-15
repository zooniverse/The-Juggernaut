require 'test_helper'

# Re-raise errors caught by the controller.
class Api::SubjectsController; def rescue_action(e) raise e end; end

class Api::SubjectsControllerTest < ActionController::TestCase
  context "Subjects Controller" do
    setup do
      @controller = Api::SubjectsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @request.env['HTTPS'] = 'on'
    end
    
    context "#show without SSL" do
      setup do
        @request.env['HTTPS'] = nil
        @subject = Factory :subject
        get :show, { :id => @subject.id, :format => :xml }
      end
      
      should respond_with :redirect
      should respond_with_content_type :html
      should redirect_to('HTTPS'){ api_subject_url(@subject, :protocol => 'https') }
    end
    
    context "#show with SSL" do
      setup do
        @subject = Factory :subject
        get :show, { :id => @subject.id, :format => :xml }
      end
      
      should respond_with :success
      should respond_with_content_type(:xml)
      
      should "return valid XML" do
        assert_select "id", "#{ @subject.id }"
        assert_select "location", "#{ @subject.location }"
        assert_select "external_ref", "#{ @subject.external_ref }"
      end
    end
    
    context "#next_subject_for_classification" do
      setup do
        @subject = Factory :subject
        get :next_subject_for_classification, { :format => :xml }
      end

      should respond_with :success
      should respond_with_content_type(:xml)
      
      should "return valid XML" do
        assert_select "id", "#{ @subject.id }"
        assert_select "location", "#{ @subject.location }"
        assert_select "external_ref", "#{ @subject.external_ref }"
      end
    end
    
    context "#next_subject_for_workflow" do
      setup do
        @workflow = Factory :workflow
        @subject = Factory :subject, :workflow_id => @workflow.id
        get :next_subject_for_workflow, { :workflow_id => @workflow.id, :format => :xml }
      end

      should respond_with :success
      should respond_with_content_type(:xml)
      
      should "return valid XML" do
        assert_select "id", "#{ @subject.id }"
        assert_select "location", "#{ @subject.location }"
        assert_select "external_ref", "#{ @subject.external_ref }"
      end
    end
    
    
    context "#create not passing an API key" do
      setup do
        @request.env['HTTPS'] = 'on'
        post :create, { }
      end
    
      should respond_with :unauthorized
    end
    
    context "#create when passing an API key but no valid subject" do
      setup do
        @request.env['HTTPS'] = 'on'
        api_login
        post :create, { :subject => {:name => "my_subject" }}, :headers => { 'content-type' => 'multipart/form-data', 'accept' => 'text/html' }
      end
      
      should "render failed" do
        assert @response.body.include?("Invalid content type")
      end
    end
    
    context "#create when passing an API key and a valid subject" do
      setup do
        @request.env['HTTPS'] = 'on'
        api_login
        file = Rack::Test::UploadedFile.new("#{ Rails.root }/test/fixtures/test_file.txt", 'text/plain')
        AWS::S3::Base.stubs(:establish_connection!).returns(:true)
        AWS::S3::S3Object.stubs(:store).returns(true)
        SiteConfig.stubs(:s3_subjects_bucket).returns('test_bucket')
        post :create, { :file => file, :subject => { :name => 'my_subject2' } }
      end
      
      should "render subject location" do
        @subject = Subject.last
        assert_equal @response.body, "http://s3.amazonaws.com/test_bucket/#{ @subject.id }.txt"
      end
    end
  end
end
