class Song < ApplicationRecord
  has_one_attached :video
  has_one_attached :audio
  has_one_attached :thumbnail

  validates :link, presence: true
end
