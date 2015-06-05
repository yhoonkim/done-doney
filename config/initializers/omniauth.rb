Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wunderlist, ENV['WUNDERLIST_CLIENT_ID'], ENV['WUNDERLIST_CLIENT_SECRET']
end