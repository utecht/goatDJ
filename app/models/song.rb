class Song < ApplicationRecord
  has_one_attached :video
  has_one_attached :audio
  has_one_attached :thumbnail

  has_many :playlist_songs, dependent: :destroy
  has_many :playlists, through: :playlist_songs

  validates :link, presence: true
end
