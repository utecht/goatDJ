class SongsController < ApplicationController
  before_action :set_song, only: %i[ show edit update destroy queue_download ]

  # GET /songs or /songs.json
  def index
    @songs = Song.all
  end

  # GET /songs/1 or /songs/1.json
  def show
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  def mass_export
    @songs = Song.all
  end

  def new_mass_import
  end

  def create_mass_import
    links = params[:links].split("\n")
    links.each do |link|
      song = Song.new(link: link)
      song.save!
      DownloadSongJob.perform_later(song.id)
    end
    redirect_to songs_url
  end

  def retry_download
    # all songs with nil state or state less than 0
    Song.where(state: nil).or(Song.where('state < 0')).each do |song|
      DownloadSongJob.perform_later(song.id)
    end
    redirect_to songs_url
  end

  def queue_download
    DownloadSongJob.perform_later(@song.id)
    redirect_to song_url(params[:id])
  end

  # POST /songs or /songs.json
  def create
    @song = Song.new(song_params)

    respond_to do |format|
      if @song.save
        DownloadSongJob.perform_later(@song.id)
        format.html { redirect_to song_url(@song), notice: "Song was successfully created." }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1 or /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to song_url(@song), notice: "Song was successfully updated." }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1 or /songs/1.json
  def destroy
    @song.destroy!

    respond_to do |format|
      format.html { redirect_to songs_url, notice: "Song was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def song_params
      params.require(:song).permit(:link, :title, :length, :rating, :views, :state, :video, :audio)
    end
end
