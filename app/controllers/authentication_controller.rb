require "jwt"

class AuthenticationController < ApplicationController
  def authenticate
    customer_id = Rails.configuration.smile[:sample_customer_id]
    private_key = Rails.application.credentials.smile[:private_key]
    expiration_time = 2*60*60
    
    payload = {
      customer_identity: {
        distinct_id: customer_id
      },
      exp: Time.now.to_i + expiration_time
    }

    signed_jwt = JWT.encode(payload, private_key, "HS256")

    render json: { jwt: signed_jwt }
  end

end
