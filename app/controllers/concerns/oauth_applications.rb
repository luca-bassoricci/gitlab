# frozen_string_literal: true

module OauthApplications
  extend ActiveSupport::Concern

  REDIS_EXPIRY_TIME = 3.minutes

  included do
    before_action :prepare_scopes, only: [:create, :update]
  end

  def prepare_scopes
    scopes = params.fetch(:doorkeeper_application, {}).fetch(:scopes, nil)

    if scopes
      params[:doorkeeper_application][:scopes] = scopes.join(' ')
    end
  end

  def load_scopes
    @scopes ||= Doorkeeper.configuration.scopes
  end

  def redis_store_secret!(user_id, secret)
    encrypted_secret = Gitlab::CryptoHelper.aes256_gcm_encrypt(secret)

    Gitlab::Redis::SharedState.with do |redis|
      redis.set(redis_shared_state_key(user_id), encrypted_secret, ex: REDIS_EXPIRY_TIME)
    end
  end

  def redis_getdel_secret(user_id)
    Gitlab::Redis::SharedState.with do |redis|
      redis_key = redis_shared_state_key(user_id)
      encrypted_secret = redis.get(redis_key)
      redis.del(redis_key)

      begin
        Gitlab::CryptoHelper.aes256_gcm_decrypt(encrypted_secret)
      rescue StandardError => ex
        logger.warn "Failed to decrypt secret value stored in Redis for key ##{redis_key}: #{ex.class}"
        encrypted_secret
      end
    end
  end

  def redis_shared_state_key(user_id)
    "gitlab:oauth_application_secret:#{user_id}"
  end
end
