import { Injectable } from '@angular/core';
import { Http } from '@angular/http';

@Injectable()
export class PlayerService {
  constructor(private http: Http) {}

  pause(): void {
    this.http.put('pause', {}).subscribe();
  }

  play(): void {
    this.http.put('play', {}).subscribe();
  }

  skip(): void {
    this.http.put('skip', {}).subscribe();
  }
}
