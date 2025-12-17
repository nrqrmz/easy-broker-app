# app/jobs/enrich_property_job.rb
# frozen_string_literal: true

class EnrichPropertyJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 30.seconds, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(property_id)
    property = Property.find(property_id)

    return if already_enriched?(property)

    detail = fetch_detail(property.public_id)

    if detail.nil?
      log "Failed to fetch #{property.public_id}, destroying"
      property.destroy
      return
    end

    if detail.description.present?
      update_property(property, detail)
      log "Enriched #{property.public_id}"
    else
      log "No description: #{property.public_id}, destroying"
      property.destroy
    end
  end

  private

  def fetch_detail(public_id)
    EasyBroker.client.properties.find(public_id)
  rescue JSON::ParserError => e
    log "Rate limited on #{public_id}, will retry"
    raise e
  rescue StandardError => e
    log "Error fetching #{public_id}: #{e.message}"
    nil
  end

  def already_enriched?(property)
    property.description.present?
  end

  def update_property(property, detail)
    property.update!(
      description: detail.description,
      latitude: detail.location&.latitude,
      longitude: detail.location&.longitude,
      street: detail.location&.street,
      postal_code: detail.location&.postal_code,
      half_bathrooms: detail.half_bathrooms,
      features: map_features(detail.features),
      operations: map_operations(detail.operations)
    )
  end

  def map_features(features)
    return [] if features.blank?
    features.map { |f| f.respond_to?(:name) ? f.name : f.to_s }
  end

  def map_operations(operations)
    return [] if operations.blank?
    operations.map do |op|
      {
        "type" => op.type,
        "price" => op.amount,
        "currency" => op.currency || "MXN",
        "formatted_price" => op.formatted_amount
      }
    end
  end

  def log(message)
    msg = "[EnrichPropertyJob] #{message}"
    puts msg
    Rails.logger.info msg
  end
end
