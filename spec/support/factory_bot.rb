RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end
end
