class User < ApplicationRecord

private

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.login = auth.info.nickname
      user.info = auth.info
      user.raw_info = auth.raw_info
    end
  end

end
