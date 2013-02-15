class Api::SubjectsController < ApplicationController
  force_ssl :only => [:show, :next_subject_for_classification, :next_subject_for_workflow, :create]
  before_filter :require_api_user, :except => [ :show, :next_subject_for_classification, :next_subject_for_workflow ]
  skip_before_filter :verify_authenticity_token, :only => :create
  respond_to :xml
  respond_to :html, :only => :create
  
  def show
    @subject = Subject.find(params[:id])
    respond_with @subject
  end
  
  def create
    @subject = Subject.create_and_upload(params)
    render :text => @subject.upload_errors.blank? ? "#{ @subject.location }" : @subject.upload_errors
  end
  
  def next_subject_for_classification
    @subject = Subject.next_for_classification.first
    respond_with @subject, :location => api_subject_url(@subject)
  end
  
  def next_subject_for_workflow
    @subject = Subject.next_for_workflow(params[:workflow_id]).first
    respond_with @subject, :location => api_subject_url(@subject)
  end
end
