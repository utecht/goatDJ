require 'open-uri'

class ProcessSongJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @song = Song.find(args[0])
    video_destination = args[1]
    duration_string = args[2]
    video_title = args[3]
    thumbnail_url = args[4]

    puts "Processing song: #{video_destination}"
    # convert minutes:seconds to seconds
    duration = duration_string.split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b }

    thumbnail_file = URI.open(thumbnail_url)

    # Create a blob for the thumbnail
    blob = ActiveStorage::Blob.create_and_upload!(
      io: thumbnail_file,
      filename: thumbnail_url
    )

    # Attach the blob to your model
    @song.thumbnail.attach(blob)

    video_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(video_destination),
      filename: video_title
    )

    @song.video.attach(video_blob)
    @song.update(title: video_title, length: duration, state: video_blob.byte_size)
    @song.save

    # delete downloaded video file
    File.delete(video_destination)
  end
end
