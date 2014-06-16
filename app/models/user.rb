class User < ActiveRecord::Base
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.nickname = auth.info.nickname
      if auth.info.urls['Twitter']
        user.url = auth.info.urls['Twitter']
      else
        user.url = auth.info.urls.first[1] if (auth.info.urls && auth.info.urls.first[1])
      end
      user.oauth_token = auth.credentials.token
      # user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
end
