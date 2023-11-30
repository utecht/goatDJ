class DownloadSongJob < ApplicationJob
  queue_as :default

  def download_video(url, song_id)
    format = 'bv[height<=720]+bestaudio'
    output_path = "ytdl/#{song_id}.mp4"
    command = "yt-dlp \"#{url}\" --format=\"#{format}\" --merge-output-format=\"mp4\" --write-thumbnail --convert-thumbnails=png --write-info-json -o \"#{output_path}\""
    puts command
    system(command)
    return output_path
  end

  def download_audio(url, song_id)
    format = 'bestaudio'
    output_path = "ytdl/#{song_id}.mp3"
    command = "yt-dlp \"#{url}\" --format=\"#{format}\" --extract-audio --audio-format=\"mp3\" -o \"#{output_path}\""
    puts command
    system(command)
    return output_path
  end

  def perform(*args)
    @song = Song.find(args[0])
    @song.update(state: 0)
    puts "Downloading song: #{@song.link}"
    video_path = download_video(@song.link, @song.id)
    audio_path = download_audio(@song.link, @song.id)
    unless File.exist?(video_path)
      puts "Failed to download video: #{video_path} does not exist"
      @song.update(state: -1)
      return
    end
    unless File.exist?(audio_path)
      puts "Failed to download audio: #{audio_path} does not exist"
      @song.update(state: -2)
      return
    end
    json_path = "ytdl/#{@song.id}.info.json"
    unless File.exist?(json_path)
      puts "Failed to download json: #{json_path} does not exist"
      @song.update(state: -3)
      return
    end
    thumbnail_path = "ytdl/#{@song.id}.png"
    unless File.exist?(thumbnail_path)
      puts "Failed to download thumbnail: #{thumbnail_path} does not exist"
      @song.update(state: -4)
      return
    end
    info = JSON.parse(File.read(json_path))
    title = info['title']
    duration = info['duration']

    @song.thumbnail.attach(io: File.open(thumbnail_path), filename: "#{@song.id}.png")
    @song.video.attach(io: File.open(video_path), filename: "#{@song.id}.mp4")
    @song.audio.attach(io: File.open(audio_path), filename: "#{@song.id}.mp3")
    @song.update(state: 1, title: title, length: duration)

    File.delete(video_path)
    File.delete(json_path)
    File.delete(thumbnail_path)
    File.delete(audio_path)
  end
end
