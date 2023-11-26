import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static values = { roomId: Number }
  static targets = [ "videoPlayer" ];

  connect() {
    this.roomChannel = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: this.roomIdValue },
      { received: data => this.processCommand(data) }
    );
  }

  processCommand(data) {
    if (data.command == "play") {
      this.videoPlayerTarget.play();
    } else if (data.command == "pause") {
      this.videoPlayerTarget.pause();
    } else if (data.command == "sync") {
      this.syncSong(data);
    }
  }

  syncSong(data) {
    console.log(data.timestamp);
    this.videoPlayerTarget.currentTime = data.timestamp;
  }

  play() {
    this.roomChannel.send({ command: 'play' });
  }

  pause() {
    this.roomChannel.send({ command: 'pause' });
  }

  sync() {
    var timestamp = this.videoPlayerTarget.currentTime;
    this.roomChannel.send({ command: 'sync', timestamp: timestamp });
  }
}
