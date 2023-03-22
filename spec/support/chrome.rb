RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  config.before(:each, headless: false, type: :system) do
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end
end
