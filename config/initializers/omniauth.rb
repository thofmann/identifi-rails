OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
# Just comment out what you don't use
  provider :developer unless Rails.env.production?
  provider :facebook, IdentifiRails::Application.config.fbID, IdentifiRails::Application.config.fbKey
  provider :twitter, IdentifiRails::Application.config.twitterKey, IdentifiRails::Application.config.twitterSecret
  provider :google_oauth2, IdentifiRails::Application.config.googleClientID, IdentifiRails::Application.config.googleClientSecret
end