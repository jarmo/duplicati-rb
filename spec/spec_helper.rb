require 'coveralls'
Coveralls.wear!

require "duplicati"

RSpec.configure do |config|
  config.color = true
  config.order = :random
end
