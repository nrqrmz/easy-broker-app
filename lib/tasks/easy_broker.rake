# frozen_string_literal: true

namespace :easy_broker do
  desc "Sync published properties from EasyBroker API"
  task sync_properties: :environment do
    puts "Starting EasyBroker property sync..."

    service = EasyBrokerSyncService.new
    stats = service.call

    puts "\nSync completed in #{stats[:elapsed]}s!"
    puts "  Created:  #{stats[:created]}"
    puts "  Skipped:  #{stats[:skipped]} (already exist)"
    puts "  Invalid:  #{stats[:invalid]} (missing required data)"
    puts "  Errors:   #{stats[:errors]}"
  end

  desc "Enqueue jobs to enrich properties with full details"
  task enrich_properties: :environment do
    total_properties = Property.count
    already_enriched = Property.where.not(description: nil).count
    pending = Property.where(description: nil)
    pending_count = pending.count

    puts "[EnrichProperties] Status:"
    puts "  Total properties: #{total_properties}"
    puts "  Already enriched: #{already_enriched}"
    puts "  Pending enrichment: #{pending_count}"

    if pending_count.zero?
      puts "[EnrichProperties] Nothing to enrich!"
      next
    end

    puts "[EnrichProperties] Enqueueing #{pending_count} jobs..."

    pending.find_each.with_index do |property, index|
      EnrichPropertyJob.set(wait: (index * 2).seconds).perform_later(property.id)

      puts "[EnrichProperties] Enqueued #{index + 1}/#{pending_count}" if ((index + 1) % 100).zero?
    end

    puts "[EnrichProperties] Done! Run 'bin/rails solid_queue:start' to process"
  end
end
