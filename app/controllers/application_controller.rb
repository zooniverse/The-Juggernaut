require 'zooniverse_user_api_token_filter'

class ApplicationController < ActionController::Base
  attr_accessor :current_zooniverse_user
  protect_from_forgery
  
  def forbidden
    render :nothing => true, :status => :forbidden, :content_type => 'application/xml'
  end
  
  def not_found
    render :file => "#{ Rails.root }/public/404.html", :status => :not_found
  end
  
  def cas_login(hash = {})
    requested = "#{ request.protocol }#{ request.host_with_port }#{ request.fullpath }"
    hash = { :service => requested }.merge(hash).stringify_keys
    querystring = hash.collect{ |key, value| "#{ CGI.escape key }=#{ CGI.escape value }" }.join('&')
    "#{ CASClient::Frameworks::Rails::Filter.client.login_url }?#{ querystring }"
  end
  helper_method :cas_login
  
  def cas_logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  helper_method :cas_logout
  
  def zooniverse_user
    session[:cas_user]
  end
  helper_method :zooniverse_user
  
  def zooniverse_user_id
    session[:cas_extra_attributes]['id']
  end
  helper_method :zooniverse_user_id
  
  def zooniverse_user_api_key
    session[:cas_extra_attributes]['api_key']
  end
  helper_method :zooniverse_user_api_key
  
  def current_zooniverse_user
    @current_zooniverse_user ||= (ZooniverseUser.find(zooniverse_user_id) if zooniverse_user)
  end
  helper_method :current_zooniverse_user
  
  def ensure_current_user
    forbidden unless current_zooniverse_user && current_zooniverse_user.id.to_s == params[:user_id].to_s
  end
  
  def require_admin_user
    redirect_to root_url unless current_zooniverse_user && current_zooniverse_user.admin?
  end
  
  def require_api_user
    authenticate_or_request_with_http_basic do |username, password|
      SiteConfig.api_username == username && SiteConfig.api_password == password
    end
  end

  def session_valid?(session)
    valid = false
    if session
      if session.is_a?(Array) #Ugh, typechecking but seems to be necessary for checking the cookie format
        unless session.empty?
          valid = true
        end
      end
    end
    valid
  end
  
  def check_or_create_zooniverse_user
    if zooniverse_user
      z = ZooniverseUser.find_or_create_by_zooniverse_user_id(zooniverse_user_id)
      z.update_attributes(:name => zooniverse_user, :api_key => zooniverse_user_api_key) if z.changed?
    end
  end
end
