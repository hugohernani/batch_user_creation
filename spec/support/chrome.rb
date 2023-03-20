RSpec.configure do
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end

  config.before(:each, type: :system, headless: false) do
    driven_by :selenium, :chrome, screen_size: [1400, 1400]
  end
end
