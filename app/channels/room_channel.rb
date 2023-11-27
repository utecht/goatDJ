class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room_id]}"
    @room = Room.find(params[:room_id])
    @room.add_listener
  end

  def unsubscribed
    @room = Room.find(params[:room_id])
    @room.remove_listener
  end

  def receive(data)
    puts data.pretty_inspect
    case data['command']
    when 'request_sync'
      puts "SYNC REQUEST"
      @room = Room.find(params[:room_id])
      data = { command: 'sync', offset: @room.song_offset }
      ActionCable.server.broadcast("room_#{params[:room_id]}", data)
    else
      ActionCable.server.broadcast("room_#{params[:room_id]}", data)
    end
  end
end
