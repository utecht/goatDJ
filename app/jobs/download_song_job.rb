require 'ytdl'
require 'open-uri'

class DownloadSongJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @song = Song.find(args[0])
    puts @song.inspect
    video = YoutubeDL.download(@song.link).call
    puts video.destination
    duration_string = video.info['duration_string']
    # convert minutes:seconds to seconds
    duration = duration_string.split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b }

    video_title = video.info['fulltitle']

    thumbnail_url = video.info['thumbnail']
    thumbnail_file = URI.open(thumbnail_url)

    @song.update(title: video_title, length: duration)

    # Create a blob for the thumbnail
    blob = ActiveStorage::Blob.create_and_upload!(
      io: thumbnail_file,
      filename: thumbnail_url
    )

    # Attach the blob to your model
    @song.thumbnail.attach(blob)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(video.destination),
      filename: video_title
    )
    @song.video.attach(video.destination)


    @song.save
  end
end
