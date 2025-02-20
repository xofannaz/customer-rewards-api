require "uri"
require "json"
require "net/http"


class PointsTransactionController < ApplicationController
  def purchase
    endpoint = "points_products"
    host = Rails.configuration.smile[:api_host]
    version = Rails.configuration.smile[:api_version]
    customer_id = Rails.configuration.smile[:sample_customer_id]

    product_id = params[:product_id]
    if !product_id.present? || !product_id.is_a?(Integer)
      render json: { error: "product_id field is required and must be an integer" }, status: :bad_request
      return
    end

    points_to_spend = params[:points_to_spend]
    if !points_to_spend.present? || !points_to_spend.is_a?(Integer)
      render json: { error: "points_to_spend field is required and must be an integer" }, status: :bad_request
      return
    end

    url = URI("#{host}/#{version}/#{endpoint}/#{product_id}/purchase")

    headers = {
      "Authorization": "Bearer #{Rails.application.credentials.smile[:private_key]}",
      "Content-Type": "application/json"
    }

    external_request = Net::HTTP::Post.new(url, headers)
    
    external_request.body = JSON.dump({
      "customer_id": customer_id,
      "points_to_spend": points_to_spend,
    })

    response = Net::HTTP.start(url.hostname, :use_ssl => true) do |http|
      http.request(external_request)
    end
    if response.is_a?(Net::HTTPSuccess)
      begin
        parsed_response = JSON.parse(response.body)
        render json: parsed_response
      rescue JSON::ParserError => e
        render json: { error: "Invalid JSON response", message: e.message }, status: :internal_server_error
      end
    else
      render json: { error: "Request failed", status: response.code, message: response.message }, status: :internal_server_error
    end
  end

  def create
    endpoint = "points_transactions"
    host = Rails.configuration.smile[:api_host]
    version = Rails.configuration.smile[:api_version]
    customer_id = Rails.configuration.smile[:sample_customer_id]
    
    points_change = params[:points_change]
    if !points_change.present? || !points_change.is_a?(Integer)
      render json: { error: "points_change field is required and must be an integer" }, status: :bad_request
      return
    end

    description = params[:description]
    if description.present? && !description.kind_of?(String)
      render json: { error: "description field must be a string" }, status: :bad_request
      return
    end

    internal_note = params[:internal_note]
    if internal_note.present? && !internal_note.kind_of?(String)
      render json: { error: "internal_note field must be a string" }, status: :bad_request
      return
    end

    url = URI("#{host}/#{version}/#{endpoint}")

    headers = {
      "Authorization": "Bearer #{Rails.application.credentials.smile[:private_key]}",
      "Content-Type": "application/json"
    }
    
    external_request = Net::HTTP::Post.new(url, headers)
    
    external_request.body = JSON.dump({
      "points_transaction": {
        "customer_id": customer_id,
        "points_change": points_change,
      }
    })

    response = Net::HTTP.start(url.hostname, :use_ssl => true) do |http|
      http.request(external_request)
    end

    if response.is_a?(Net::HTTPSuccess)
      begin
        parsed_response = JSON.parse(response.body)
        render json: parsed_response
      rescue JSON::ParserError => e
        render json: { error: "Invalid JSON response", message: e.message }, status: :internal_server_error
      end
    else
      render json: { error: "Request failed", status: response.code, message: response.message }, status: :internal_server_error
    end
  end
end
