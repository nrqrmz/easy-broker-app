# frozen_string_literal: true

class EasyBrokerSyncService
  BATCH_SIZE = 100

  def initialize
    @client = EasyBroker.client
    @stats = { created: 0, skipped: 0 }
  end

  def call
    start_time = Time.current
    output "Starting property sync..."

    existing_ids = Property.pluck(:public_id).to_set
    output "Found #{existing_ids.size} existing properties in DB"

    sync_from_listing(existing_ids)

    elapsed = Time.current - start_time
    output "Completed in #{elapsed.round(1)}s - #{format_stats}"

    @stats.merge(elapsed: elapsed.round(1))
  end

  private

  def sync_from_listing(existing_ids)
    batch = []
    count = 0

    @client.properties.search(search: { statuses: [:published] }).find_each do |property|
      count += 1

      if existing_ids.include?(property.public_id)
        @stats[:skipped] += 1
      else
        batch << map_from_listing(property)

        if batch.size >= BATCH_SIZE
          insert_batch(batch)
          batch = []
        end
      end

      output "Progress: #{count} processed..." if (count % 200).zero?
    end

    insert_batch(batch) if batch.any?
    output "Total processed: #{count}"
  end

  def map_from_listing(p)
    location_str = extract_location_string(p.location)

    {
      public_id: p.public_id,
      title: p.title,
      description: nil,
      property_type: p.property_type,
      location: location_str,
      region: parse_location_part(location_str, :region),
      city: parse_location_part(location_str, :city),
      city_area: parse_location_part(location_str, :city_area),
      street: nil,
      postal_code: nil,
      latitude: nil,
      longitude: nil,
      bedrooms: p.bedrooms,
      bathrooms: p.bathrooms,
      half_bathrooms: nil,
      parking_spaces: p.parking_spaces,
      lot_size: p.lot_size,
      construction_size: p.construction_size,
      operations: map_operations(p.operations),
      title_image_full: p.title_image_full,
      title_image_thumb: p.title_image_thumb,
      features: [],
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  def extract_location_string(location)
    return location if location.is_a?(String)
    return location.name if location.respond_to?(:name)
    return location[:name] if location.is_a?(Hash)

    nil
  end

  def parse_location_part(location_str, part)
    return nil if location_str.blank?

    parts = location_str.split(", ").map(&:strip)
    case part
    when :city_area then parts.size >= 3 ? parts[0] : nil
    when :city then parts.size >= 2 ? parts[-2] : nil
    when :region then parts.last
    end
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

  def insert_batch(batch)
    return if batch.empty?

    Property.insert_all(batch)
    @stats[:created] += batch.size
    output "Inserted batch of #{batch.size} properties (total: #{@stats[:created]})"
  end

  def format_stats
    "Created: #{@stats[:created]}, Skipped: #{@stats[:skipped]}"
  end

  def output(message)
    msg = "[EasyBrokerSync] #{message}"
    puts msg
    Rails.logger.info msg
  end
end
