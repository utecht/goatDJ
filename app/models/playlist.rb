class Playlist < ApplicationRecord
  belongs_to :user
  has_many :playlist_songs, dependent: :destroy
  has_many :songs, through: :playlist_songs

  validates :name, presence: true

  def add_song(song)
    self.songs << song
  end

  def remove_song(song)
    self.songs.delete(song)
  end
end
