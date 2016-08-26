import { it, describe, expect } from '@angular/core/testing';
import { WebSocketService } from '../../src/services/web_socket_service';

describe('WebSocketService', () => {
  describe('registerListener', () => {
    it('should register the listener and fire the callback on message receive', () => {
      let socket = new WebSocket('ws://mock');
      let service = new WebSocketService(socket);
      let value = 'original value';
      service.registerListener('current_track', (data: any) => value = data);
      socket.onmessage(new MessageEvent('stub', { data: JSON.stringify({ current_track: 'new value' }) }));
      expect(value).toEqual('new value');
    });

    it('should not fire the callback if the event is valid but not for the registered listener', () => {
      let socket = new WebSocket('ws://mock');
      let service = new WebSocketService(socket);
      let value = 'original value';
      service.registerListener('current_track', (data: any) => value = data);
      socket.onmessage(new MessageEvent('stub', { data: JSON.stringify({ foo: 'new value' }) }));
      expect(value).toEqual('original value');
    });

    it('should not fire the callback if the event is invalid', () => {
      let socket = new WebSocket('ws://mock');
      let service = new WebSocketService(socket);
      let value = 'original value';
      service.registerListener('current_track', (data: any) => value = data);
      socket.onmessage(new MessageEvent('stub', { data: '{}' }));
      expect(value).toEqual('original value');
    });
  });
});
