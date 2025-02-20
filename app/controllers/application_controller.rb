class ApplicationController < ActionController::API
    # Handle StandardError exceptions globally
    rescue_from StandardError, with: :internal_server_error
    after_action :enable_cors

    private

    def enable_cors
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
      response.headers['Access-Control-Request-Method'] = '*'
      response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    def internal_server_error(exception)
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
end
