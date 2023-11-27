class PlayNextSongJob < ApplicationJob
  queue_as :default

  def perform(room_id, song_id)
    @room = Room.find(room_id)
    if @room.current_song.id == song_id
      puts "=========== NEXT SONG ==============="
      @room.next_song
    end
  end
end
