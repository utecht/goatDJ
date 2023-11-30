require 'open-uri'

class ProcessSongJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @song = Song.find(args[0])
    duration_string = args[1]
    video_title = args[2]
    thumbnail_url = args[3]

    puts "Processing song: #{@song.link}"
    # convert minutes:seconds to seconds
    duration = duration_string.split(':').map(&:to_i).inject(0) { |a, b| a * 60 + b }

    @song.update(title: video_title, length: duration)

    thumbnail_file = URI.open(thumbnail_url)

    # Create a blob for the thumbnail
    blob = ActiveStorage::Blob.create_and_upload!(
      io: thumbnail_file,
      filename: thumbnail_url
    )

    # Attach the blob to your model
    @song.thumbnail.attach(blob)
  end
end
