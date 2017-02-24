json.playlists do
  json.array! playlists do |playlist|
    json.id playlist.id
    json.enabled playlist.enabled?
    json.name playlist.name
    json.user_id playlist.user_id
  end
end
json.users do
  json.array! users do |user|
    json.id user.id
    json.enabled user.enabled?
    json.name user.name
  end
end
