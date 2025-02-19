require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should return error when customer_id is missing" do
    post authenticate_url, params: {}
    assert_response :bad_request
    assert_includes @response.body, "customer_id is required"
  end

  test "should return JWT when customer_id is provided" do
    fixed_time = Time.utc(2025, 2, 18, 12, 0, 0)
    Timecop.freeze(fixed_time) do
      private_key = ENV["SMILE_PRIVATE_KEY"]
      customer_id = "12345"
      post authenticate_url, params: { customer_id: customer_id }

      assert_response :success
      assert_includes @response.body, "jwt"
      assert_includes @response.content_type, "application/json"

      parsed_response = JSON.parse(@response.body)["jwt"]
      jwt_payload = JWT.decode(parsed_response,  private_key, { algorithm: "HS256" }).first

      assert_equal fixed_time.to_i + 2 * 60 * 60, jwt_payload["exp"]
      assert_equal customer_id, jwt_payload["customer_identity"]["distinct_id"]
    end
  end
end
