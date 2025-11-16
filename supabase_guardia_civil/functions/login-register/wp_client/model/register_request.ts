// register_request.ts
export class RegisterRequest {
  username: string;
  firstName: string;
  lastName: string;
  name: string;
  email: string;
  password: string;

  constructor(
    username: string = '',
    firstName: string = '',
    lastName: string = '',
    name: string = '',
    email: string = '',
    password: string = ''
  ) {
    this.username = username;
    this.firstName = firstName;
    this.lastName = lastName;
    this.name = name;
    this.email = email;
    this.password = password;
  }

  static fromJson(json: any): RegisterRequest {
    return new RegisterRequest(
      json.username || '',
      json.first_name || '',
      json.last_name || '',
      json.name || '',
      json.email || '',
      json.password || ''
    );
  }

  toJson(): any {
    return {
      username: this.username,
      first_name: this.firstName,
      last_name: this.lastName,
      name: this.name,
      email: this.email,
      password: this.password,
    };
  }
}