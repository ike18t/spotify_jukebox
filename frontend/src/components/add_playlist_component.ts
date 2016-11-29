import { Component, Input, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'add-playlist',
  template: `
    <div class="add-playlist">
      <form action="playlists" method="POST">
        <label for="playlists">
          Add a playlist!
        </label>
        <fieldset>
          <input id="add_playlist_url_input" type="url" name="playlist_url" placeholder="Enter a Spotify playlist URL" required />
          <input id="add_playlist_submit" type="submit" value="+" />
        </fieldset>
      </form>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AddPlaylistComponent {}
