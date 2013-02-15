class HomeController < ApplicationController
  before_filter CASClient::Frameworks::Rails::GatewayFilter, :only => :index
  before_filter CASClient::Frameworks::Rails::Filter, :only => :profile
  before_filter :check_or_create_zooniverse_user, :only => :index
  
  def index
  end
  
  def profile
    @user = current_zooniverse_user
    @recents = current_zooniverse_user.classifications
    @favourites = current_zooniverse_user.favourites
  end
end
