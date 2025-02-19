class ApplicationController < ActionController::API
    # Handle StandardError exceptions globally
    rescue_from StandardError, with: :internal_server_error

    private

    def internal_server_error(exception)
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
end
