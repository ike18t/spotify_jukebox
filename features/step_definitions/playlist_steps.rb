Given 'I am on the home page' do
  @browser.goto 'http://localhost:4567'
end

When /^I add the playlist (.*)$/ do |playlist_url|
  @browser.button(:id, 'add_playlist_button').click
  @browser.text_field(:id, 'playlist_url').set(playlist_url)
  @browser.button(:text, 'ok').click
end

Then /^I should see the name (.*) with user id (\d+)$/ do |name, id|
  expect(@browser.element(:id, id)).to exist
  name_in_browser = @browser.element(:class, 'user-name').text
  expect(name_in_browser.downcase).to eq(name.downcase)
end

Then /^I should see the playlist (.*) with playlist id (.*)$/ do |name, id|
  expect(@browser.element(:id, id)).to exist
  name_in_browser = @browser.element(:class, 'playlist-name').attribute_value('innerHTML')
  expect(name_in_browser.downcase).to eq(name.downcase)
end
