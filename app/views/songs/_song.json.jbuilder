json.extract! song, :id, :link, :title, :length, :rating, :views, :state, :video, :audio, :created_at, :updated_at
json.url song_url(song, format: :json)
json.video url_for(song.video)
json.audio url_for(song.audio)
