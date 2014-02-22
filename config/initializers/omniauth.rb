OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '73899182844579', 'fdf9dcf8bfb9935886cf5c947e9ab30d'
end