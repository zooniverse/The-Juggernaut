class Api::FavouritesController < ApplicationController
  force_ssl :only => [:index, :show, :create, :destroy]
  before_filter :find_associated, :only => :index
  before_filter :require_api_user
  
  respond_to :xml
  
  def index
    return forbidden unless @source
    @favourites = @source.favourites.page(params[:page])
    
    if params[:from] && params[:to]
      @favourites = @favourites.between_dates(params[:from], params[:to])
    end
    
    respond_with :api, @favourites
  end
  
  def show
    @favourite = Favourite.find(params[:id])
    respond_with :api, @favourite
  end
  
  def create
    @favourite = Favourite.new(params[:favourite])
    @favourite.zooniverse_user_id = params[:favourite][:zooniverse_user_id]
    @favourite.save
    respond_with :api, @favourite
  end
  
  def destroy
    @favourite = Favourite.find(params[:id])
    @favourite.destroy
    respond_with :api, @favourite, :status => :ok
  end
  
  private
  
  def find_associated
    if params[:subject_id]
      @source = Subject.find(params[:subject_id])
    elsif params[:user_id]
      @source = ZooniverseUser.find(params[:user_id])
    end
  end
end
