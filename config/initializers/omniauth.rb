OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, IdentifiRails::Application.config.fbID, IdentifiRails::Application.config.fbKey
  provider :twitter, IdentifiRails::Application.config.twitterKey, IdentifiRails::Application.config.twitterSecret
end