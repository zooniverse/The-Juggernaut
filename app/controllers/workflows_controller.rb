class WorkflowsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :login_from_cookie
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :classify
  before_filter :check_or_create_zooniverse_user, :only => :classify
  respond_to :html
  respond_to :js, :only => [:next_task_or_end, :rewind, :add_favourites]
  
  def classify
    if active_session?
      workflow_task_id = session[:current_workflow_task_id]
      @workflow_task = WorkflowTask.find(workflow_task_id)
    else #user is starting the workflow
      if params[:id]
        @workflow_task = Workflow.find(params[:id]).starting_task
      else
        @workflow_task = Workflow.default.starting_task
      end
    end
    
    @workflow = @workflow_task.workflow
    
    # Warning, assigning two variables here
    assign_current_or_next_subjects_for_classification(@workflow)
    
    unless zooniverse_user
      flash[:warning] = t 'workflows.controllers.not_logged_in'
    end
  end
  
  def next_task_or_end
    workflow_answer = WorkflowAnswer.find(params[:id])
    subject_ids = session[:current_subject_ids]
    build_result([subject_ids], workflow_answer)
    
    if workflow_answer.ends_workflow?
      if zooniverse_user
        Classification.create_with_subjects_and_annotations(classification_from_result)
      else
        flash[:warning] = t 'workflows.controllers.not_logged_in'
      end
      reset_workflow_session # we're done here so clear out old classification history
    else
      @workflow_task = WorkflowTask.find(workflow_answer.next_workflow_task_id)
      session[:current_workflow_task_id] = @workflow_task.id
    end
  end
  
  def rewind
    if valid_results_session?
      begin
        rewind_to_task_id = params[:id].to_i
        session[:result].each_with_index do |result, index|
          if result[:workflow_task_id].to_i == rewind_to_task_id
            @position = index
          end
        end
        
        new_session = session[:result].slice(0, @position)
        
        @workflow_task = WorkflowTask.find(params[:id])
        session[:current_workflow_task_id] = @workflow_task.id
        session[:result] = new_session
      rescue
        reset_workflow_session # session is invalid, reset everything and start again
        flash[:notice] = t 'workflows.controllers.problem'
        redirect_to :action => "classify"
      end
    else
      reset_workflow_session # session is invalid, reset everything and start again
      flash[:notice] = t 'workflows.controllers.problem'
      redirect_to :action => "classify"
    end
  end
  
  def classification_from_result
    begin
      results = session[:result]
      subjects = results.first[:subjects]
      started = session[:started]
      ended = Time.now.utc
      
      posted_subjects = []
      subjects.each do |subject|
        posted_subjects << { :id => subject }
      end
      
      posted_annotations = []
      results.each do |result|
        posted_annotations << { :task_id => result[:task_id], :answer_id => result[:answer_id] }
      end
      
      workflow_id = session[:current_workflow_id]
      posted = { :started => started, :ended => ended, :locale => 'en', :workflow_id => workflow_id, :zooniverse_user_id => zooniverse_user_id, :subjects => posted_subjects, :annotations => posted_annotations }
    rescue
      posted = nil
    end
    posted
  end
  
  def add_favourites
    return unless current_zooniverse_user && session[:current_subject_ids]
    session[:current_subject_ids].each do |subject_id|
      current_zooniverse_user.favourites.find_or_create_by_subject_id(:subject_id => subject_id)
    end
    
    render :nothing => true
  end
  
  def reset_workflow_session
    session[:current_workflow_id] = nil
    session[:current_workflow_task_id] = nil
    session[:current_subject_ids] = nil
    session[:current_subject_locations] = nil
    session[:result] = nil
    session[:started] = nil
  end
  
  def assign_current_or_next_subjects_for_classification(workflow)
    unless session[:current_subject_ids] && session[:current_subject_locations]
      # Get new selection of subjects for classification if we don't already have them
      subjects = Subject.next_for_classification
      session[:current_subject_ids] = subjects.collect { |a| a.id }
      session[:current_subject_locations] = subjects.collect { |a| a.location }
      session[:current_workflow_id] = workflow.id
      session[:started] = Time.now.utc
    end
  end
  
  def valid_results_session?
    session_valid?(session[:result])
  end
  
  def active_session?
    session[:current_workflow_task_id].nil? ? false : true
  end
  
  def build_result(subjects, workflow_answer)
    initialize_results
    session[:result].push({ :subjects => subjects,
                            :workflow_answer_id => workflow_answer.id,
                            :answer_id => workflow_answer.answer.id,
                            :workflow_task_id => workflow_answer.workflow_task.id,
                            :task_id => workflow_answer.workflow_task.task.id })
  end
  
  def initialize_results
    if session[:result]
      session[:result]
    else
      session[:result] = []
    end
  end
end
