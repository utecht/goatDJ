class PlaylistsController < ApplicationController
  before_action :set_playlist, only: %i[ show edit update destroy add_song remove_song ]

  # GET /playlists or /playlists.json
  def index
    @playlists = Playlist.all
  end

  # GET /playlists/1 or /playlists/1.json
  def show
    @songs = Song.all
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
  end

  # GET /playlists/1/edit
  def edit
  end

  def add_song
    @song = Song.find(params[:song_id])
    @playlist.add_song(@song)
    redirect_to playlist_url(@playlist)
  end

  def remove_song
    @song = Song.find(params[:song_id])
    @playlist.remove_song(@song)
    redirect_to playlist_url(@playlist)
  end

  # POST /playlists or /playlists.json
  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user = current_user

    respond_to do |format|
      if @playlist.save
        format.html { redirect_to playlist_url(@playlist), notice: "Playlist was successfully created." }
        format.json { render :show, status: :created, location: @playlist }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playlists/1 or /playlists/1.json
  def update
    respond_to do |format|
      if @playlist.update(playlist_params)
        format.html { redirect_to playlist_url(@playlist), notice: "Playlist was successfully updated." }
        format.json { render :show, status: :ok, location: @playlist }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1 or /playlists/1.json
  def destroy
    @playlist.destroy!

    respond_to do |format|
      format.html { redirect_to playlists_url, notice: "Playlist was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playlist
      @playlist = Playlist.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def playlist_params
      params.require(:playlist).permit(:name)
    end
end
