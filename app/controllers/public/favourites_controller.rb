class Public::FavouritesController < ApplicationController
  before_filter :ensure_current_user
  prepend_around_filter ZooniverseUserApiTokenFilter.new
  respond_to :xml
  respond_to :atom, :only => [:index]
  
  def index
    @user = current_zooniverse_user
    @favourites = @user.favourites.page(params[:page])
    
    if params[:from] && params[:to]
      @favourites = @favourites.between_dates(params[:from], params[:to])
    end
    
    respond_with :public, @favourites
  end
  
  def show
    @favourite = Favourite.find(params[:id])
    respond_with :public, @favourite
  end
  
  def create
    @favourite = current_zooniverse_user.favourites.create(params[:favourite])
    respond_with :public, @favourite
  end
  
  def destroy
    @favourite = current_zooniverse_user.favourites.where(:id => params[:id]).first
    return not_found unless @favourite
    
    @favourite.destroy
    respond_with :public, @favourite, :status => :ok
  end
end
