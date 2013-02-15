class Api::AnnotationsController < ApplicationController
  force_ssl :only => [:index, :show]
  before_filter :find_associated, :only => :index
  before_filter :require_api_user
  skip_before_filter :verify_authenticity_token, :only => :s3_store
  
  def index
    if params[:from] && params[:to]
      if @task
        @annotations = @task.annotations.all(:conditions => ["created_at > ? AND created_at < ?", params[:from], params[:to]])
      else
        @denied = true
      end
    else
      if @task
        @annotations = @task.annotations.all(:order => "id desc", :limit => 30)
      else
        @denied = true
      end
    end
    
    respond_to do |format|
      if @denied == true
        format.xml  { render :nothing => true, :status => :forbidden }
      else
        format.xml
      end
    end
  end
  
  def show
    @annotation = Annotation.find(params[:id])
    
    respond_to do |format|
      format.xml
    end
  end

  private
  
  def find_associated
    if params[:task_id]
      @task = Task.find_by_id(params[:task_id])
    end
  end
end
