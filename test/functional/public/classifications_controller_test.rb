require 'test_helper'

class Public::ClassificationsControllerTest < ActionController::TestCase
  context "Public Classifications Controller" do
    setup do
      @controller = Public::ClassificationsController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end
    
    # should_have_instance_methods :check_user
    
    context "When submitting a classification with no api_key" do
      setup do
        @request.env['HTTPS'] = 'on'    
        @zooniverse_user = Factory :zooniverse_user
        options = { :user_id => @zooniverse_user.id, :format => :xml }
        post :create, options        
      end

      should respond_with 403
    end
    
    context "When submitting a classification with the wrong api_key" do
      setup do
        @request.env['HTTPS'] = 'on'    
        @zooniverse_user = Factory :zooniverse_user, :api_key => "something"
        options = { :user_id => @zooniverse_user.id, :api_key => "wrong", :format => :xml }
        post :create, options        
      end

      should respond_with 403
    end
    
    context "When submitting a classification with the correct api key but no classification" do
      setup do
        @request.env['HTTPS'] = 'on'    
        @zooniverse_user = Factory :zooniverse_user, :api_key => "something"
        Turbo::Queue.stubs(:new).returns(true)
        options = { :user_id => @zooniverse_user.id, :api_key => "something", :format => :xml }
        post :create, options
      end

      should respond_with 422
    end
    
    context "When submitting a classification with the correct api key with a classification block" do
      setup do
        @request.env['HTTPS'] = 'on'    
        @zooniverse_user = Factory :zooniverse_user, :api_key => "something"
        queue = mock()
        queue.stubs(:send).returns(true)
        Turbo::Queue.stubs(:new).returns(queue)
        options = { :user_id => @zooniverse_user.id, :api_key => "something", :format => :xml, :classification => { :something_valid => "hello" } }
        post :create, options
      end

      should respond_with 201
    end
    # FIX ME - need to do something with fake web here to mock out the post to SQS
    # context "When submitting a classification with the wrong api_key" do
    #   setup do
    #     @request.env['HTTPS'] = 'on'    
    #     @zooniverse_user = Factory :zooniverse_user
    #     options = { :user_id => @zooniverse_user.id, :api_key => "123456", :data => "kpsjGcNvq5szuN+QEGMf7XqZkFVycR/krIWs3+r2HdzzTM47xO4w9ya9xE+ukVMwjNlmzx3psP0qW3bKZ84KPr5v+Zr3wGr5RzpCeFOTQDR8jWrWe2lLSlRMBMDKk3K0LaSJOWcXRHtzOQFqPO48Edf8qK4lU+jAvbqFlqJnmdmjebbL4KDzU3Gt68IKuzgL7rcCrlYoMwRhW9G0VGYKUAAO3b6uZGas4I7VksU71IN4iVW1k0PFqig392IEyV5WP30z0jCgu3VsBDwnIe4+hkpZ71J+6YBiHyt9E3XeEy076KZsG3vmclyeX1WlUmkrVLLOK21p7g/XtS2WFKqwtA=="}
    #     post :create, options        
    #   end
    # 
    #   should respond_with 201
    # end
  end
end
