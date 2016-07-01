import { bootstrap } from '@angular/platform-browser-dynamic';
import { provide } from '@angular/core';
import { HTTP_PROVIDERS } from '@angular/http';
import { enableProdMode } from '@angular/core';
import { WebSocketToken } from './tokens/web_socket_token';
import { JukeboxApplication } from './components/jukebox_application';

if (process.env.ENV === 'production') {
  enableProdMode();
}

bootstrap(JukeboxApplication, [HTTP_PROVIDERS,
                               provide(WebSocketToken, {
                                 useValue: new WebSocket(`ws://${window.location.host}/websocket_connect`)
                               })]);
