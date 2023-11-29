require 'ytdl'

class DownloadSongJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @song = Song.find(args[0])
    @song.update(state: 0)
    puts "Downloading song: #{@song.link}"
    YoutubeDL::Command.config.default_options = { 
      format: 'bv[height<=720]+bestaudio',
      merge_output_format: 'mp4'
     }
    state = YoutubeDL.download(@song.link)
      .on_progress do |state:, line:|
        puts "Progress: #{state.progress}%"
      end
      .on_error do |state:, line:|
        puts "Error: #{state.error}"
        @song.update(state: -1)
      end
      .on_complete do |state:, line:|
        puts "Completed song download: #{state.destination}"
        ProcessSongJob.perform_later(@song.id, state.destination.to_s, state.info['duration_string'], state.info['fulltitle'], state.info['thumbnail'])
      end
      .call
  end
end
