import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = { id: Number, currentTime: Number, songStart: Number, audio: Boolean }
  static targets = [ "videoPlayer", "listenerCount", "currentlyPlaying" ];

  connect() {
    console.log("Connected to room channel: " + this.idValue);
    this.roomChannel = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: this.idValue },
      { received: data => this.processCommand(data) }
    );
    this.videoPlayerTarget.currentTime = this.currentTimeValue - this.songStartValue;
    this.videoPlayerTarget.play();
  }

  disconnect() {
    console.log("disconnecting controller");
    this.videoPlayerTarget.pause();
    this.roomChannel.unsubscribe();
  }

  syncSong() {
    console.log("Setting player timestamp: " + (this.currentTimeValue - this.songStartValue));
    this.videoPlayerTarget.currentTime = this.currentTimeValue - this.songStartValue;
    this.videoPlayerTarget.play();
  }

  processCommand(data) {
    console.log(data);
    if (data.command == "play") {
      this.videoPlayerTarget.play();
    } else if (data.command == "pause") {
      this.videoPlayerTarget.pause();
    } else if (data.command == "sync") {
      this.songStartValue = data.songStart;
      this.currentTimeValue = data.currentTime;
      this.syncSong();
    } else if (data.command == "next_song") {
      this.playNext(data);
      this.roomChannel.send({ command: 'ack_next_song', guid: this.myId });
    } else if (data.command == "init_sync") {
      this.currentTimeValue = data.timestamp;
      this.myId = data.guid;
      this.syncSong();
    } else if (data.command == "resync") {
      this.currentTimeValue = data.timestamp;
      this.syncSong();
    } else if (data.command == "listener_count") {
      this.listenerCountTarget.innerHTML = data.listener_count;
    }
  }

  playNext(data) {
    if (this.audioValue) {
      this.videoPlayerTarget.src = data.audio_url;
    } else {
      this.videoPlayerTarget.src = data.song_url;
    }
    this.currentlyPlayingTarget.innerHTML = data.song_title;
    this.songStartValue = data.songStart;
    this.currentTimeValue = data.currentTime;
    this.syncSong();
    this.videoPlayerTarget.play();
  }

  play() {
    this.videoPlayerTarget.play();
    this.roomChannel.send({ command: 'init_sync' });
  }

  pause() {
    this.videoPlayerTarget.pause();
  }

  sync() {
    this.roomChannel.send({ command: 'request_sync' });
  }
}
