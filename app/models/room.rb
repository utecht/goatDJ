class Room < ApplicationRecord
	include Rails.application.routes.url_helpers
	validates :name, presence: true

	@playlists = {}
	@song_starts = {}
	@listener_count = Hash.new(0)

	class << self
		attr_accessor :playlists
		attr_accessor :song_starts
		attr_accessor :listener_count
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
		if listener_count > 0
	        song_url = rails_blob_url(self.current_song.video, only_path: true) if self.current_song&.video&.attached?
		    ActionCable.server.broadcast("room_#{self.id}", {command: 'next_song', song_url: song_url})
			self.start_song
		end
	end

	def start_song
		Room.song_starts[self.id] = Time.now
		PlayNextSongJob.set(wait: self.current_song.length).perform_later(self.id, self.current_song.id)
	end

	def end_song
		Room.song_starts[self.id] = nil
	end

	def song_offset
		Room.song_starts[self.id] ? Time.now - Room.song_starts[self.id] : 0
	end

	def listener_count
		Room.listener_count[self.id]
	end

	def add_listener
		Room.listener_count[self.id] += 1
		if self.listener_count == 1
			unless self.current_song
				self.add_songs_to_playlist(Song.all.shuffle)
			end
			self.start_song
		end
	end

	def remove_listener
		Room.listener_count[self.id] -= 1
		if self.listener_count == 0
			self.end_song
		end
	end

end
