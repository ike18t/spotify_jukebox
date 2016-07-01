import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { User } from '../models/user';

@Injectable()
export class UserService {
  constructor(private http: Http) {}

  enableUser(user: User) {
    this.http.put(`/users/${user.id}/enable`, {}).subscribe();
  }

  disableUser(user: User) {
    this.http.put(`/users/${user.id}/disable`, {}).subscribe();
  }
}
