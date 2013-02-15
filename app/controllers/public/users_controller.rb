class Public::UsersController < ApplicationController
  before_filter :ensure_current_user
  prepend_around_filter ZooniverseUserApiTokenFilter.new
  respond_to :xml
  
  def show
    @user = current_zooniverse_user
    respond_with @user
  end
end
