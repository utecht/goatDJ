class RoomsController < ApplicationController
  before_action :set_room, only: %i[ show edit update destroy shuffle_songs next_song add_playlist ]

  # GET /rooms or /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1 or /rooms/1.json
  def show
    @song = @room.current_song
    @playlists = []
    if current_user
      @playlists = current_user.playlists
    end
    unless @song
      @room.add_songs_to_playlist(Song.all.sample(1))
      @song = @room.current_song
    end
    puts params
    @audio = params[:audio].present?
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  def shuffle_songs
    @room.shuffle_playlist
    redirect_to room_url(@room)
  end

  def add_playlist
    @playlist = Playlist.find(params[:playlist_id])
    @room.add_songs_to_playlist(@playlist.songs)
    redirect_to room_url(@room)
  end

  def next_song
    @room.next_song
    return true
    # redirect_to room_url(@room)
  end

  # POST /rooms or /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to room_url(@room), notice: "Room was successfully created." }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1 or /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to room_url(@room), notice: "Room was successfully updated." }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1 or /rooms/1.json
  def destroy
    @room.destroy!

    respond_to do |format|
      format.html { redirect_to rooms_url, notice: "Room was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.require(:room).permit(:name, :description)
    end
end
