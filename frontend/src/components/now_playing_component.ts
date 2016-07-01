import { Component, Input, ChangeDetectionStrategy } from '@angular/core';
import { PlayerService } from '../services/player_service';
import { Track } from '../models/track';
import { User } from '../models/user';

@Component({
  selector: 'now-playing',
  template: `
    <div class="now-playing">
      <div class="album-artist"> {{ track?.artists }} </div>
      <div class="album-title"> {{ track?.name }} </div>
      <div class="album-art" [ngStyle]='{ "background-image": "url(" + track?.image + ")" }'>
        <div class="album-art-overlay">
          <div class="album-art-overlay-play-toggle fa" (click)="togglePlay(playing)" [ngClass]="{ 'fa-play': !playing, 'fa-pause': playing }"></div>
        </div>
      </div>
      <div class="skip-button">
        <div class="fa fa-step-forward" (click)="skip()"></div>
      </div>
      <div class="playlist-user">
        <div class="user-avatar"></div>
        <div class="user-name">
          Brought to you by {{ user?.name || user?.id }}
        </div>
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [PlayerService]
})
export class NowPlayingComponent {
  @Input() track: Track;
  @Input() user: User;
  @Input() playing: boolean;

  constructor(private playerService: PlayerService) {}

  togglePlay(playing: boolean): void {
    if (playing) {
      this.playerService.pause();
    }
    else {
      this.playerService.play();
    }
  }

  skip(): void {
    this.playerService.skip();
  }
}
