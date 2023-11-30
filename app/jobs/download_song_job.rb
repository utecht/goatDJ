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
      .on_unparsable do |state:, line:|
        puts "Unparsable: #{line}"
      end
      .on_progress do |state:, line:|
        puts "Progress: #{state.progress}%"
      end
      .on_error do |state:, line:|
        puts "Error: #{state.error}"
        @song.update(state: -1)
      end
      .on_complete do |state:, line:|
        puts "Info Json: #{line}"
        # file = File.open(state.info)
        # puts file
        # info_json = JSON.parse(file.read)
        info_json = state.info
        ProcessSongJob.perform_later(@song.id, info_json['duration_string'], info_json['fulltitle'], info_json['thumbnail'])
      end
      .on_destination do |state:, line:|
        puts "Destination: #{state.destination}"
        AttachVideoJob.perform_later(@song.id, state.destination.to_s)
      end
      .on_unclear_exit_state do |state:, line:|
        puts "Unclear Exit State: #{state}"
      end
      .call
    puts "Outside call: #{@song.link}"
    state = YoutubeDL.download(@song.link, format: 'mp3')
      .on_destination do |state:, line:|
        puts "Destination: #{state.destination}"
        AttachAudioJob.perform_later(@song.id, state.destination.to_s)
      end
      .call
  end
end
