require 'ostruct'

EasyBroker.configure do |config|
  config.api_key = ENV.fetch('EASYBROKER_API_KEY')
  config.api_root_url = EasyBroker::STAGING_API_ROOT_URL
end
