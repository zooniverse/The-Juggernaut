class Api::ClassificationsController < ApplicationController
  force_ssl :only => [:index, :create, :show]
  before_filter :find_associated, :only => :index
  before_filter :require_api_user
  
  def index
    if params[:from] && params[:to]
      if @user
        @classifications = @user.classifications.where('created_at > ? AND created_at < ?', params[:from], params[:to]).limit(20).all
      else
        @denied = true
      end
    elsif params[:page]
      offset = (params[:page].to_i - 1) * 20 #send back classifications in groups of 20
      if @user
        @classifications = @user.classifications.all(:order => "id desc", :limit => 20, :offset => offset)
      else
        @denied = true
      end
    else
      if @user
        @classifications = @user.classifications.all(:order => "id desc", :limit => 20)
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
    @classification = Classification.find(params[:id])

    respond_to do |format|
      format.xml
    end
  end
  
  def create    
    respond_to do |format|
      if Classification.create_with_subjects_and_annotations(params[:classification])
        format.xml  { render :nothing => true, :status => :created }
      else
        format.xml  { render :nothing => true, :status => :unprocessable_entity }
      end
    end
  end
  
  private
  
  def find_associated
    if params[:user_id]
      @user = ZooniverseUser.find_by_zooniverse_user_id(params[:user_id])
    end
  end
end
