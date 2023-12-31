class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :password, length: {minimum: 6}, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true
  validates :email, presence: true

  has_many :playlists, dependent: :destroy
end
