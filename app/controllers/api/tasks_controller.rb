class Api::TasksController < ApplicationController
  force_ssl :only => [:index, :show]
  before_filter :require_api_user
  respond_to :xml
  
  def index
    @tasks = Task.find(:all)
    respond_with @tasks
  end
  
  def show
    @task = Task.find(params[:id])
    respond_with @task
  end
end
