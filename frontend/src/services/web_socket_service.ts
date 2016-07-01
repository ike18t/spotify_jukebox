import { Inject, Injectable } from '@angular/core';
import { WebSocketToken } from '../tokens/web_socket_token';

type MessageType = 'users' | 'playlists' | 'current_track' | 'current_user' | 'play_status';

@Injectable()
export class WebSocketService {
  private registrationLookup: Map<string, Array<Function>> = new Map<string, Array<Function>>();

  constructor(@Inject(WebSocketToken) private webSocket: WebSocket) {
    webSocket.onmessage = (messageEvent: MessageEvent) => {
      let json = JSON.parse(messageEvent.data);
      Object.keys(json).forEach((messageType: string) => {
        (this.registrationLookup.get(messageType) || []).forEach((callback: Function) => {
          callback.call(this, json[messageType]);
        });
      });
    };
  }

  registerListener = (messageType: MessageType, callback: Function) => {
    if (!this.registrationLookup.has(messageType)) {
      this.registrationLookup.set(messageType, []);
    }
    let callbacks = this.registrationLookup.get(messageType);
    callbacks.push(callback);
    this.registrationLookup.set(messageType, callbacks);
  }
}
