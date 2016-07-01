import { Component, Input, ChangeDetectionStrategy } from '@angular/core';
import { UserService } from '../services/user_service';
import { PlaylistService } from '../services/playlist_service';
import { User } from '../models/user';
import { Playlist } from '../models/playlist';

@Component({
  selector: 'user-list',
  template: `
    <ul class="users entity-list">
      <li class="user" *ngFor="let user of users" [ngClass]="{ 'disabled': !user.enabled }" id="{{ user.id }}">
        <div class="name user-name" (click)="toggleUser(user)">
          {{ user.name || user.id }}
        </div>
        <ul class="playlists entity-list">
          <li class="playlist" *ngFor="let playlist of playlistsByUser(user)" id="{{ playlist.id }}" [ngClass]="{ 'disabled': !playlist.enabled }">
            <label class="name transformed transform-extrude" (click)="togglePlaylist(playlist)">
              <span class="content playlist-name"> {{ playlist.name }} </span>
              <span class="right side"></span>
              <span class="bottom side"></span>
            </label>
          </li>
        </ul>
      </li>
    </ul>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [UserService, PlaylistService]
})
export class UserListComponent {
  @Input() users: Array<User>;
  @Input() playlists: Array<Playlist>;

  constructor(private userService: UserService, private playlistService: PlaylistService) {}

  playlistsByUser(user: User): Array<Playlist> {
    return this.playlists.filter((playlist: Playlist) => playlist.userId === user.id);
  }

  toggleUser(user: User): void {
    if (user.enabled) {
      this.userService.disableUser(user);
    }
    else {
      this.userService.enableUser(user);
    }
  }

  togglePlaylist(playlist: Playlist): void {
    if (playlist.enabled) {
      this.playlistService.disablePlaylist(playlist);
    }
    else {
      this.playlistService.enablePlaylist(playlist);
    }
  }
}
