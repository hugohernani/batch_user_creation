RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :job

  config.around(:each, inline_sidekiq: true) do |test|
    Sidekiq::Testing.inline! do
      test.run
    end
  end
end
