import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = { id: Number, offset: Number }
  static targets = [ "videoPlayer" ];

  connect() {
    console.log("Connected to room channel: " + this.idValue);
    this.roomChannel = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: this.idValue },
      { received: data => this.processCommand(data) }
    );
    this.videoPlayerTarget.currentTime = this.offsetValue;
    console.log("Setting player timestamp: " + this.offsetValue);
    this.roomChannel.send({ command: 'request_sync' });
  }

  processCommand(data) {
    console.log(data);
    if (data.command == "play") {
      this.videoPlayerTarget.play();
    } else if (data.command == "pause") {
      this.videoPlayerTarget.pause();
    } else if (data.command == "sync") {
      this.syncSong(data);
    } else if (data.command == "next_song") {
      this.playNext(data);
    }
  }

  playNext(data) {
    this.videoPlayerTarget.src = data.song_url;
    this.videoPlayerTarget.currentTime = 0;
    this.videoPlayerTarget.play();
  }

  syncSong(data) {
    // if(Math.abs(this.videoPlayerTarget.currentTime - data.offset) > .1) {
    this.videoPlayerTarget.currentTime = data.offset + 0.01;
    // }
  }

  play() {
    this.roomChannel.send({ command: 'play' });
  }

  pause() {
    this.roomChannel.send({ command: 'pause' });
  }

  sync() {
    var timestamp = this.videoPlayerTarget.currentTime;
    this.roomChannel.send({ command: 'sync', offset: timestamp });
  }
}
