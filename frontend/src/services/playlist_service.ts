import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Playlist } from '../models/playlist';

@Injectable()
export class PlaylistService {
  constructor(private http: Http) {}

  enablePlaylist(playlist: Playlist) {
    this.http.put(`/playlists/${playlist.id}/enable`, {}).subscribe();
  }

  disablePlaylist(playlist: Playlist) {
    this.http.put(`/playlists/${playlist.id}/disable`, {}).subscribe();
  }
}
