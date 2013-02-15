class ZooniverseUserApiTokenFilter
  def before(controller)
    return true unless controller.params[:api_key]
    zooniverse_user = ZooniverseUser.find_by_api_key(controller.params[:api_key])
    if zooniverse_user
      controller.current_zooniverse_user = zooniverse_user
    else
      return true
    end
  end
  
  def after(controller)
    controller.current_zooniverse_user = nil
  end
end
