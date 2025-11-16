// user.ts
import { Membership } from './membership.ts';

export class User {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  username: string;
  betatester?: boolean;
  memberships: Membership[];

  constructor(
    id: number = -1,
    firstName: string = '',
    lastName: string = '',
    email: string = '',
    username: string = '',
    betatester: boolean = false,
    memberships: Membership[] = []
  ) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.username = username;
    this.betatester = betatester;
    this.memberships = memberships;
  }

  static get empty(): User {
    return new User(-1, '', '', '', '', false, []);
  }

  get isEmpty(): boolean {
    return this.id === -1;
  }

  static fromJson(json: any): User {
    const memberships = json.memberships?.map((m: any) => Membership.fromJson(m)) || [];
    
    return new User(
      json.id || -1,
      json.first_name || '',
      json.last_name || '',
      json.email || '',
      json.username || '',
      json.betatester || false,
      memberships
    );
  }

  toJson(): any {
    return {
      id: this.id,
      first_name: this.firstName,
      last_name: this.lastName,
      email: this.email,
      username: this.username,
      betatester: this.betatester,
      memberships: this.memberships.map(m => m.toJson()),
    };
  }

  copyWith(updates: Partial<User>): User {
    return new User(
      updates.id ?? this.id,
      updates.firstName ?? this.firstName,
      updates.lastName ?? this.lastName,
      updates.email ?? this.email,
      updates.username ?? this.username,
      updates.betatester ?? this.betatester,
      updates.memberships ?? this.memberships
    );
  }
}