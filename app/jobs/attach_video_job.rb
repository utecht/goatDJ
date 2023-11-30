class AttachVideoJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @song = Song.find(args[0])
    video_destination = args[1]

    unless File.exist?(video_destination)
      puts "Failed to attach video to song: #{video_destination} does not exist"
      return
    end

    video_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(video_destination),
      filename: @song.title ? "#{@song.title}.mp4" : 'unknown_song.mp4'
    )

    @song.video.attach(video_blob)
    @song.update(state: video_blob.byte_size)

    # delete downloaded video file
    File.delete(video_destination)
  end
end
