class AttachAudioJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @song = Song.find(args[0])
    audio_destination = args[1]

    unless File.exist?(audio_destination)
      puts "Failed to attach audio to song: #{audio_destination} does not exist"
      return
    end
    
    audio_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(audio_destination),
      filename: @song.title ? "#{@song.title}.mp3" : 'unknown_song.mp3'
    )

    @song.audio.attach(audio_blob)

    # delete downloaded video file
    File.delete(audio_destination)
  end
end
