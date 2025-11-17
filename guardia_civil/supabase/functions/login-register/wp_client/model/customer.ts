// customer.ts
import { Membership } from './membership.ts';

export class Customer {
  id: string;
  memberships: Membership[];

  constructor(id: string = '', memberships: Membership[] = []) {
    this.id = id;
    this.memberships = memberships;
  }

  static fromJson(json: any): Customer {
    const memberships = json.memberships?.map((m: any) => Membership.fromJson(m)) || [];
    
    return new Customer(
      json.id || '',
      memberships
    );
  }

  toJson(): any {
    return {
      id: this.id,
      memberships: this.memberships.map(m => m.toJson()),
    };
  }
}