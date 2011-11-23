CoctsApp::Application.config.action_mailer.default_url_options = {
  :host => URL_HOST
}
CoctsApp::Application.config.action_mailer.raise_delivery_errors = true
CoctsApp::Application.config.action_mailer.delivery_method = :smtp
CoctsApp::Application.config.action_mailer.smtp_settings = {
  :address => 'mawida.com.ar',
  :domain => 'mawida.com.ar',
  :port => 25,
  :user_name => 'soporte@cocts.com.ar',
  :password => APP_CONFIG['smtp_password'],
  :authentication => :plain
}