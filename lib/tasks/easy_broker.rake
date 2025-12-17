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
end
