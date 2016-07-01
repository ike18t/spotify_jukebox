import { Component, OnInit, Inject, ChangeDetectionStrategy } from '@angular/core';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';
import { Subject } from 'rxjs/Subject';
import { WebSocketService } from '../services/web_socket_service';
import { User } from '../models/user';
import { Playlist } from '../models/playlist';
import { Track } from '../models/track';
import { UserListComponent } from './user_list_component';
import { NowPlayingComponent } from './now_playing_component';
import { AddPlaylistComponent } from './add_playlist_component';

@Component({
  selector: 'jukebox-application',
  template: `
    <div class="pure-g">
      <div class="pure-u-1-2">
        <user-list
          [users]="users | async"
          [playlists]="playlists | async">
        </user-list>
      </div>

      <div class="pure-u-1-2">
        <now-playing
          [track]="currentTrack | async"
          [user]="currentUser | async"
          [playing]="playing | async">
        </now-playing>
      </div>
    </div>
    <add-playlist></add-playlist>
  `,
  directives: [UserListComponent, NowPlayingComponent, AddPlaylistComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [WebSocketService]
})
export class JukeboxApplication {
  private users: BehaviorSubject<Array<User>> = new BehaviorSubject<Array<User>>([]);
  private playlists: Subject<Array<Playlist>> = new Subject<Array<Playlist>>();
  private currentTrack: Subject<Track> = new Subject<Track>();
  private currentUser: Subject<User> = new Subject<User>();
  private playing: Subject<boolean> = new Subject<boolean>();

  constructor(private webSocketService: WebSocketService) {
    webSocketService.registerListener('users', (users: any) => {
      this.users.next(users.map((user: any) => new User(user.id, user.name, user.enabled)));
    });

    webSocketService.registerListener('playlists', (playlists: any) => {
      this.playlists.next(playlists.map((playlist: any) => new Playlist(playlist.id, playlist.user_id, playlist.name, playlist.enabled)));
    });

    webSocketService.registerListener('current_track', (track: any) => {
      this.currentTrack.next(new Track(track.name, track.artists, track.album, track.image));
    });

    webSocketService.registerListener('current_user', (current_user: any) => {
      this.currentUser.next(this.users.value.find((user) => user.id === current_user.id));
    });

    webSocketService.registerListener('play_status', (playStatus: any) => {
      this.playing.next(playStatus.playing);
    });
  }
}
