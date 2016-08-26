require 'rspec/expectations'
require 'watir'
require 'rake'

Browser = Watir::Browser
browser = Browser.new :firefox

Before do
  @browser = browser
end

at_exit do
  browser.close
end
