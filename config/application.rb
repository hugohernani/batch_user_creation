require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BatchUserCreation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.generators do |generator|
      generator.test_framework :rspec
      generator.helper false
      generator.assets false
      generator.view_specs false
    end

    config.active_job.queue_adapter = :sidekiq
  end
end
