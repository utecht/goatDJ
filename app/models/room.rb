class Room < ApplicationRecord
	include Rails.application.routes.url_helpers
	validates :name, presence: true

	def set_playlist(playlist)
	    REDIS.set("rooms:#{self.id}:playlist", playlist.pluck(:id).to_json)
	end

	def add_song_to_playlist(song)
		self.add_songs_to_playlist([song])
	end

	def add_songs_to_playlist(songs)
		current_playlist = self.playlist
		current_playlist += songs
		self.set_playlist(current_playlist)
	end

	def remove_song_from_playlist(song)
		current_playlist = self.playlist
		current_playlist.delete(song.id)
		self.set_playlist(current_playlist)
	end

	def playlist
		r = REDIS.get("rooms:#{self.id}:playlist")
		return [] unless r
		Song.find(JSON.parse(r))
	end

	def current_song
		r = REDIS.get("rooms:#{self.id}:playlist") 
		return nil unless r
		playlist = JSON.parse(r)
		return nil if playlist.empty?
		Song.find(playlist.first)
	end

	def shuffle_playlist
		current_playlist = self.playlist.shuffle
		self.set_playlist(current_playlist)
		self.next_song
	end

	def next_song
		current_playlist = self.playlist.drop(1)
		self.set_playlist(current_playlist)
		if listener_count > 0
			if self.playlist.empty?
				self.add_song_to_playlist(Song.all.sample)
			end
	        song_url = rails_blob_url(self.current_song.video, only_path: true) if self.current_song&.video&.attached?
			self.start_song
		    ActionCable.server.broadcast("room_#{self.id}", {command: 'next_song', song_url: song_url, songStart: self.song_start_time, currentTime: Time.now.to_f })
		end
	end

	def song_start
		REDIS.get("rooms:#{self.id}:song_start").to_f || 0
	end

	def start_song
	    REDIS.set("rooms:#{self.id}:song_start", Time.now.to_f)
		PlayNextSongJob.set(wait: self.current_song.length).perform_later(self.id, self.current_song.id)
	end

	def end_song
	    REDIS.set("rooms:#{self.id}:song_start", nil)
	end

	def song_start_time
		self.song_start ? self.song_start : Time.now.to_f
	end

	def listener_count
		REDIS.get("rooms:#{self.id}:listener_count").to_i
	end

	def add_listener
		REDIS.incr("rooms:#{self.id}:listener_count")
		if self.listener_count == 1
			unless self.current_song
				self.add_songs_to_playlist(Song.all.shuffle)
			end
			self.start_song
		end
	end

	def remove_listener
		puts "user left"
		REDIS.decr("rooms:#{self.id}:listener_count")
		puts "listener count: #{self.listener_count}"
		if self.listener_count == 0
			# self.end_song
		end
	end

end
