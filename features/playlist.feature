Feature: Playlist
  Scenario: Add playlist
    Given I am on the home page
    When I add the playlist http://open.spotify.com/user/1295855412/playlist/7Co7hqxAQFSAV7bMtyCGp0
    Then I should see the name Isaac Datlof with user id 1295855412
    Then I should see the playlist Work it! with playlist id 7Co7hqxAQFSAV7bMtyCGp0
