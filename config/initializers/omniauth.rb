# frozen_string_literal: true

require Rails.root.join('lib', 'omniauth', 'strategies', 'samedi')

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :samedi, ENV.fetch('CLIENT_ID'), ENV.fetch('CLIENT_SECRET'), request_path: '/samedi/oauth', callback_path: '/samedi/oauth/callback'
end
