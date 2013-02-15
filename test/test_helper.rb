ENV['RAILS_ENV'] = 'test'
require 'simplecov'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda/rails'

module Shoulda
  class Context
    def should_not_set_workflow_session
      should_not set_session :current_workflow_id
      should_not set_session :current_workflow_task_id
      should_not set_session :current_subject_ids
      should_not set_session :current_subject_locations
      should_not set_session :result
      should_not set_session :started
    end
  end
  
  # Apparently, FlashHash doesn't define values anymore...
  module ActionController
    module Matchers
      class SetTheFlashMatcher
        alias_method :flash_before, :flash
        
        def flash
          return @flash if @flash
          @flash = flash_before
          
          @flash.instance_eval do
            def values
              keys.collect{ |key| self[key] }
            end
          end
          
          @flash
        end
      end
    end
  end
end

module ActionController
  class TestCase
    def should_set_workflow_session_with(workflow, workflow_task, subjects = nil)
      subjects ||= [Factory(:subject, :workflow_id => workflow.id), Factory(:subject, :workflow_id => workflow.id), Factory(:subject, :workflow_id => workflow.id)]
      subjects = [subjects] unless subjects.is_a?(Array)
      
      assert_equal workflow.id, session[:current_workflow_id]
      
      if workflow_task.nil?
        assert_equal nil, session[:current_workflow_task_id]
      else
        assert_equal workflow_task.id, session[:current_workflow_task_id]
      end
      
      assert_equal subjects.collect(&:id), session[:current_subject_ids]
      assert_equal subjects.collect(&:location), session[:current_subject_locations]
    end
  end
end

class ActiveSupport::TestCase
  def setup
    Rails.cache.clear
  end
  
  def teardown
    CASClient::Frameworks::Rails::Filter.unstub(:filter)
    CASClient::Frameworks::Rails::GatewayFilter.unstub(:filter)
  end
  
  def api_login
    @request.env['HTTPS'] = 'on'
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(SiteConfig.api_username, SiteConfig.api_password)
  end
  
  def admin_cas_login(user = nil)
    @user = user || Factory(:admin_user)
    set_cas_session_for @user
  end
  
  def standard_cas_login(user = nil)
    @user = user || Factory(:zooniverse_user)
    set_cas_session_for @user
  end
  
  def set_cas_session_for(user)
    @request.session[:cas_user] = user.name
    @request.session[:cas_extra_attributes] = {}
    @request.session[:cas_extra_attributes]['id'] = user.id
    @request.session[:cas_extra_attributes]['api_key'] = user.api_key
    
    CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(true)
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(true)
  end
  
  def without_cas_login
    CASClient::Frameworks::Rails::GatewayFilter.stubs(:filter).returns(false)
    CASClient::Frameworks::Rails::Filter.stubs(:filter).returns(false)
  end
  
  def build_workflow
    @workflow = Factory :workflow
    
    @first_workflow_task = Factory :workflow_task, :workflow => @workflow
    @first_workflow_answer_1 = Factory :workflow_answer, :workflow_task_id => @first_workflow_task.id
    @first_workflow_answer_2 = Factory :workflow_answer, :workflow_task_id => @first_workflow_task.id
    
    @second_workflow_task = Factory :workflow_task, :parent_id => @first_workflow_task.id, :workflow => @workflow
    @second_workflow_answer_1 = Factory :workflow_answer, :workflow_task_id => @second_workflow_task.id
    @second_workflow_answer_2 = Factory :workflow_answer, :workflow_task_id => @second_workflow_task.id
    
    @third_workflow_task = Factory :workflow_task, :parent_id => @second_workflow_task.id, :workflow => @workflow
    @third_workflow_answer_1 = Factory :workflow_answer, :workflow_task_id => @third_workflow_task.id
    @third_workflow_answer_2 = Factory :workflow_answer, :workflow_task_id => @third_workflow_task.id
    
    3.times{ Factory(:subject) }
    @subjects = Subject.all
  end
  
  def build_workflow_session_with(workflow, workflow_task, subjects = nil)
    subjects ||= [Factory(:subject, :workflow_id => workflow.id), Factory(:subject, :workflow_id => workflow.id), Factory(:subject, :workflow_id => workflow.id)]
    subjects = [subjects] unless subjects.is_a?(Array)
    
    @request.session['current_workflow_id'] = workflow.id
    @request.session['current_workflow_task_id'] = workflow_task.nil? ? nil : workflow_task.id
    @request.session['current_subject_ids'] = subjects.collect(&:id)
    @request.session['current_subject_locations'] = subjects.collect(&:location)
    @request.session['started'] = Time.now
  end
  
  def clear_workflow_session
    @request.session[:current_workflow_id] = nil
    @request.session[:current_workflow_task_id] = nil
    @request.session[:current_subject_ids] = nil
    @request.session[:current_subject_locations] = nil
    @request.session[:result] = nil
    @request.session[:started] = nil
  end
end
