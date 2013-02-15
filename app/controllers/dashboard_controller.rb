class DashboardController < ApplicationController
  before_filter :require_admin_user
  respond_to :html, :js
  
  def index
    grouped_users = ZooniverseUser.count(:group => "DATE(created_at)")
    @total_user_count = ZooniverseUser.count
    total = 0
    @total_users = {}
    grouped_users.each_pair do |date,value|
      total += value
      @total_users[date] = total
    end
    
    @users = ZooniverseUser.order('created_at DESC').page(params[:page])
    @classifications = Classification.count(:group => "DATE(created_at)")
  end
end
