class Room < ApplicationRecord
	validates :name, presence: true

	@playlists = {}

	class << self
		attr_accessor :playlists
	end

	def add_song_to_playlist(song)
		Room.playlists[self.id] ||= []
		Room.playlists[self.id] << song
	end

	def add_songs_to_playlist(songs)
		Room.playlists[self.id] ||= []
		Room.playlists[self.id] += songs
	end

	def remove_song_from_playlist(song)
		Room.playlists[self.id] ||= []
		Room.playlists[self.id].delete(song)
	end

	def playlist
		Room.playlists[self.id] || []
	end

	def current_song
		self.playlist.first
	end

	def next_song
		self.playlist.shift
	end

end
