json.current_track do
  json.name track.name
  json.artists track.artists.map(&:name).join(', ')
  json.album track.album.name
  json.image track.album.images.first['url']
end

json.current_user do
  json.id user.id
  json.name user.name
  json.avatar_url.image_url
end
