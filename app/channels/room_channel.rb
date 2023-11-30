class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:room_id]}"
    @room = Room.find(params[:room_id])
    @room.add_listener
    current_time = Time.now.to_f
    transmit({ command: 'init_sync', timestamp: current_time })
    ActionCable.server.broadcast("room_#{params[:room_id]}", { command: 'listener_count', listener_count: @room.listener_count })
  end

  def unsubscribed
    @room = Room.find(params[:room_id])
    @room.remove_listener
    ActionCable.server.broadcast("room_#{params[:room_id]}", { command: 'listener_count', listener_count: @room.listener_count })
  end

  def receive(data)
    puts data.pretty_inspect
    case data['command']
    when 'init_sync'
      current_time = Time.now.to_f
      transmit({ command: 'init_sync', timestamp: current_time })
    when 'request_sync'
      puts "SYNC REQUEST"
      @room = Room.find(params[:room_id])
      data = { command: 'sync', currentTime: Time.now.to_f, songStart: @room.song_start_time }
      ActionCable.server.broadcast("room_#{params[:room_id]}", data)
    else
      ActionCable.server.broadcast("room_#{params[:room_id]}", data)
    end
  end
end
