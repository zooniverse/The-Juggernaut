class Public::ClassificationsController < ApplicationController
  force_ssl :only => [:create]
  before_filter :check_user
  prepend_around_filter ZooniverseUserApiTokenFilter.new
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def create
    # Send to SQS (whether it's an iPhone or Android classification)
    queue = Turbo::Queue.new(SiteConfig.sqs_queue)
    
    if params[:classification]
      queue.send(params[:classification])
      success = true
    else
      success = false
    end
    
    respond_to do |format|
      if success
        format.xml { render :nothing => true, :status => :created }
        format.json { render :nothing => true, :status => :created }
      else
        format.xml { render :nothing => true, :status => :unprocessable_entity }
        format.json { render :nothing => true, :status => :unprocessable_entity }
      end
    end
  end
  
  def check_user
    unless current_zooniverse_user && current_zooniverse_user.zooniverse_user_id.to_s == params[:user_id].to_s
      respond_to do |format|
        format.xml { render :nothing => true, :status => :forbidden }
      end
    end
  end
end
