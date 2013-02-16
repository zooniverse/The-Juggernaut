if Rails.env.production?
  Airbrake.configure do |config|
    config.api_key = 'AIRBRAKE_API_KEY'
  end
end
