class Api::UsersController < ApplicationController
  force_ssl :only => [:show]
  before_filter :require_api_user
  respond_to :xml
  
  def show
    @user = ZooniverseUser.find(params[:id])
    respond_with @user
  end
end
