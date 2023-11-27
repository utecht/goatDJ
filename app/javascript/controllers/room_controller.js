import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = { id: Number, currentTime: Number, songStart: Number }
  static targets = [ "videoPlayer", "listenerCount" ];

  connect() {
    console.log("Connected to room channel: " + this.idValue);
    this.roomChannel = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: this.idValue },
      { received: data => this.processCommand(data) }
    );
    this.videoPlayerTarget.currentTime = this.currentTimeValue - this.songStartValue;
    this.videoPlayerTarget.play();
  }

  syncSong() {
    this.videoPlayerTarget.currentTime = this.currentTimeValue - this.songStartValue;
    console.log("Setting player timestamp: " + (this.currentTimeValue - this.songStartValue));
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
    } else if (data.command == "init_sync") {
      this.currentTimeValue = data.timestamp;
      this.syncSong();
    } else if (data.command == "listener_count") {
      this.listenerCountTarget.innerHTML = data.listener_count;
    }
  }

  playNext(data) {
    this.videoPlayerTarget.src = data.song_url;
    this.songStartValue = data.songStart;
    this.currentTimeValue = data.currentTime;
    this.syncSong();
    this.videoPlayerTarget.play();
  }

  play() {
    this.roomChannel.send({ command: 'play' });
  }

  pause() {
    this.roomChannel.send({ command: 'pause' });
  }

  sync() {
    this.roomChannel.send({ command: 'request_sync' });
  }
}
