xml.instruct!
xml.user do |user|
  user.id              @user.id
  user.classifications @user.classifications.size
  user.last_active_at  @user.last_active_at
  user.last_classified @user.last_classified
end
