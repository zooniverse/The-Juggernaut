class Public::SubjectsController < ApplicationController
  before_filter :check_user
  prepend_around_filter ZooniverseUserApiTokenFilter.new
  
  def show
    @subject = Subject.find(params[:id])

    respond_to do |format|
      format.xml
    end
  end
  
  def check_user
    unless @current_zooniverse_user
      respond_to do |format|
         format.xml { render :nothing => true, :status => :forbidden }
         format.atom { render :nothing => true, :status => :forbidden }
       end
    end
  end
end
