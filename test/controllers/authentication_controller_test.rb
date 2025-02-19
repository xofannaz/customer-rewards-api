require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should return JWT" do
    fixed_time = Time.utc(2025, 2, 18, 12, 0, 0)
    Timecop.freeze(fixed_time) do
      private_key = Rails.application.credentials.smile[:private_key]
      customer_id = Rails.configuration.smile[:sample_customer_id]
      post authenticate_url

      assert_response :success
      assert_includes @response.body, "token"
      assert_includes @response.content_type, "application/json"

      parsed_response = JSON.parse(@response.body)["token"]
      jwt_payload = JWT.decode(parsed_response,  private_key, { algorithm: "HS256" }).first

      assert_equal fixed_time.to_i + 2 * 60 * 60, jwt_payload["exp"]
      assert_equal customer_id, jwt_payload["customer_identity"]["distinct_id"]
    end
  end
end
